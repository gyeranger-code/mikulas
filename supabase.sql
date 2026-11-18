-- Mikulás húzás – Supabase adatbázis
-- Supabase → SQL Editor → New query → másold be az egészet → Run

create extension if not exists pgcrypto with schema extensions;

-- Résztvevők és a párosítás. Kívülről (API) közvetlenül NEM olvasható,
-- csak az alábbi függvényeken keresztül.
create table if not exists public.participants (
  name        text primary key,
  target      text not null,
  claimed_by  uuid,
  claimed_at  timestamptz
);

create table if not exists public.admin_config (
  id       int primary key default 1 check (id = 1),
  pin_hash text not null
);

alter table public.participants enable row level security;
alter table public.admin_config enable row level security;
revoke all on public.participants from anon, authenticated;
revoke all on public.admin_config from anon, authenticated;

-- PIN ellenőrzés (belső)
create or replace function public._check_pin(p_pin text)
returns boolean
language plpgsql security definer
set search_path = public, extensions
as $$
declare h text;
begin
  select pin_hash into h from admin_config where id = 1;
  if h is null then return false; end if;
  return h = crypt(p_pin, h);
end $$;

-- Névlista: ki húzott már (a párosítást NEM adja ki)
create or replace function public.list_names()
returns table(name text, claimed boolean)
language sql security definer
set search_path = public
as $$
  select p.name, p.claimed_by is not null from participants p order by p.name;
$$;

-- Húzás: ha a név még szabad, lefoglalja ennek a telefonnak és visszaadja a párt.
-- Ugyanaz a telefon később újra megnézheti. Más telefon nem.
create or replace function public.claim(p_name text, p_token uuid)
returns text
language plpgsql security definer
set search_path = public
as $$
declare t text; c uuid;
begin
  update participants
     set claimed_by = p_token, claimed_at = now()
   where participants.name = p_name and claimed_by is null
  returning target into t;
  if t is not null then return t; end if;

  select p.target, p.claimed_by into t, c from participants p where p.name = p_name;
  if not found then raise exception 'not_found'; end if;
  if c = p_token then return t; end if;
  raise exception 'already_claimed';
end $$;

-- Admin: sorsolás (első alkalommal ez állítja be a PIN-t; utána csak a helyes PIN-nel lehet újrasorsolni)
create or replace function public.admin_setup(p_pin text, p_names text[])
returns int
language plpgsql security definer
set search_path = public, extensions
as $$
declare h text; arr text[]; n int; i int;
begin
  select pin_hash into h from admin_config where id = 1;
  if h is not null and h <> crypt(p_pin, h) then raise exception 'bad_pin'; end if;
  if p_pin !~ '^\d{6,}$' then raise exception 'short_pin'; end if;

  select array_agg(x order by random()) into arr
    from (select distinct btrim(regexp_replace(u, '\s+', ' ', 'g')) as x
            from unnest(p_names) u) s
   where x <> '';
  n := coalesce(array_length(arr, 1), 0);
  if n < 3 then raise exception 'too_few'; end if;

  delete from participants where true;
  -- egy nagy kör: senki nem húzza magát, mindenkit pontosan egyszer húznak
  for i in 1..n loop
    insert into participants(name, target) values (arr[i], arr[(i % n) + 1]);
  end loop;

  insert into admin_config(id, pin_hash) values (1, crypt(p_pin, gen_salt('bf')))
  on conflict (id) do update set pin_hash = excluded.pin_hash;
  return n;
end $$;

-- Admin: állapot (opcionálisan a párokkal)
create or replace function public.admin_list(p_pin text, p_with_targets boolean default false)
returns table(name text, claimed boolean, target text)
language plpgsql security definer
set search_path = public
as $$
begin
  if not _check_pin(p_pin) then raise exception 'bad_pin'; end if;
  return query
    select p.name, p.claimed_by is not null,
           case when p_with_targets then p.target else null end
      from participants p order by p.name;
end $$;

-- Admin: egy név feloldása (ha valaki rossz névre nyomott)
create or replace function public.admin_unlock(p_pin text, p_name text)
returns void
language plpgsql security definer
set search_path = public
as $$
begin
  if not _check_pin(p_pin) then raise exception 'bad_pin'; end if;
  update participants set claimed_by = null, claimed_at = null where participants.name = p_name;
end $$;

-- Jogosultságok
revoke execute on function public._check_pin(text) from public, anon, authenticated;
revoke execute on function public.list_names() from public;
revoke execute on function public.claim(text, uuid) from public;
revoke execute on function public.admin_setup(text, text[]) from public;
revoke execute on function public.admin_list(text, boolean) from public;
revoke execute on function public.admin_unlock(text, text) from public;
grant execute on function public.list_names() to anon, authenticated;
grant execute on function public.claim(text, uuid) to anon, authenticated;
grant execute on function public.admin_setup(text, text[]) to anon, authenticated;
grant execute on function public.admin_list(text, boolean) to anon, authenticated;
grant execute on function public.admin_unlock(text, text) to anon, authenticated;
