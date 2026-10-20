# Kotoba

Beiträge zum Japanischlernen auf Deutsch – gebaut mit [Emanote](https://emanote.srid.ca), veröffentlicht unter https://garic12.github.io/kotoba/.

## Neuer Beitrag

- **Artikel:** `_vorlagen/artikel.md` kopieren nach `Artikel/<Kategorie>/<titel>.md` (Kategorien: Kanji, Grammatik, Tools, Ressourcen). `date:` im Frontmatter setzen.
- **Notiz:** `_vorlagen/notiz.md` kopieren nach `Notizen/YYYY-MM-DD-titel.md`. Das Datum kommt aus dem Dateinamen.
- **Neue Kategorie:** `Artikel/<Kategorie>.md` nach dem Muster der bestehenden anlegen.

Dateinamen ohne Leerzeichen und Umlaute. Bilder kommen nach `Bilder/`. Syntax-Beispiele: `_vorlagen/spickzettel.md`.

`_vorlagen/` und `docs/` werden nicht veröffentlicht (siehe `.emanoteignore`).

## Veröffentlichen

Push auf `master` → GitHub Actions (`.github/workflows/publish.yaml`) baut und deployt nach GitHub Pages.
