# 🎅 Mikulás húzás

Egy telefonos PWA a mikulásnapi húzáshoz: a telefon körbejár, mindenki rányom a saját nevére, és megtudja, kinek kell ajándékot vennie.

- A párosítás induláskor, egyetlen véletlenszerű körként készül el: senki nem húzhatja saját magát, és az utolsó ember sem akad el.
- Minden adat csak a telefon böngészőjében (localStorage) van tárolva. A nevek nincsenek benne a repóban.
- Offline is működik (service worker).

## Használat
1. Nyisd meg a GitHub Pages linket a telefonon, és add hozzá a kezdőképernyőhöz.
2. Másold be a neveket (soronként egyet), adj meg egy admin PIN-t, majd indítsd a sorsolást.
3. Add körbe a telefont.

Admin (⚙️ + PIN): újra megmutathatod valakinek, kit húzott, megnézheted az összes párt, vagy nullázhatsz mindent.

> Ne töröld a böngészési adatokat, és ne használj inkognitó módot, amíg mindenki nem húzott.
