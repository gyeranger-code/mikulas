# 🎅 Mikulás húzás

Egy közös link, mindenki a saját telefonján húz. A sorsolás egyszer, a szerveren készül (Supabase), egyetlen nagy körként: senki nem húzhatja magát, és mindenkit pontosan egyszer húznak.

- Aki rányom egy névre, annak a telefonjához kötődik a név: más telefonról már nem nyitható meg, ő maga viszont később újra megnézheti.
- A párosítás közvetlenül nem olvasható az adatbázisból, csak a saját párját kapja meg mindenki.
- Becsületalapú: a még nem húzott neveket bárki megnyithatja, ezért mindenki csak a sajátjára nyomjon.

## Beállítás
1. Supabase (új vagy meglévő projekt – minden `mikulas_` előtagú, mást nem érint) → SQL Editor → futtasd a `supabase.sql`-t.
2. Project Settings → API: a Project URL-t és az anon/publishable key-t írd be az `index.html` tetején.
3. GitHub → Settings → Pages → Deploy from branch → `main` / root.
4. Nyisd meg a linket → ⚙️ → találj ki egy PIN-t (min. 6 számjegy) → nevek bemásolása → Sorsolás.
5. Mehet a link a csoportba.

Szervező (⚙️ + PIN): állapot, név feloldása (ha valaki rossz névre nyomott), összes pár, újrasorsolás.
