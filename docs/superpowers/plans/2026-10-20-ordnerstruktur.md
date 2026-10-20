# Kotoba Ordnerstruktur – Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Emanote-Template aufräumen und ein leeres Gerüst (Artikel/Kategorien, Notizen, Timeline, Vorlagen) anlegen.

**Architecture:** Reine Markdown/YAML-Dateien für Emanote. Übersichtsseiten listen Beiträge automatisch per Emanote-Query (`path:` + `{.timeline}`); Vorlagen und Doku werden per `.emanoteignore` aus dem Build ausgeschlossen.

**Tech Stack:** Emanote (Nix-Flake), GitHub Actions → GitHub Pages.

**Spec:** `docs/superpowers/specs/2026-10-20-ordnerstruktur-design.md`

## Global Constraints

- Kein Artikel-/Lerninhalt schreiben – nur Struktur, Queries, Vorlagen, Syntax-Beispiele.
- Seitensprache Deutsch; `page.lang: de`.
- Kategorien: Kanji, Grammatik, Tools, Ressourcen.
- Kein lokaler Build; Prüfung lokal nur per Shell-Checks, echter Build über GitHub Actions (`publish.yaml`, Branch `master`).
- Unverändert lassen: `flake.nix`, `flake.lock`, `.github/workflows/*`, `.envrc`, `.gitignore`, `LICENSE`.
- Dateinamen ASCII, ohne Leerzeichen (URLs mit `urlStrategy: pretty`).

## Review Focus

1. Kategorieseite listet sich selbst oder andere Kategorien → Queries müssen `Artikel/<Kat>/*` sein, Timeline-Artikel-Query `Artikel/*/*` (schließt `Artikel/Kanji.md` aus). Check in Task 2.
2. Notiz ohne Datumspräfix im Dateinamen erscheint undatiert/unsortiert → Vorlage und README nennen das Schema `YYYY-MM-DD-titel.md`. Check in Task 3/4.
3. `_vorlagen/` oder `docs/` landen trotzdem auf der Website → `.emanoteignore` mit `_vorlagen/**` und `docs/**`. Check in Task 1, final in Task 5.
4. Bild-Dateinamen mit Leerzeichen/Umlauten brechen `![[...]]` → Spickzettel weist darauf hin. Check in Task 3.
5. HTML-Kommentar vor dem Frontmatter macht das Frontmatter ungültig → Kommentar in Vorlagen steht erst nach dem schließenden `---`. Check in Task 3.

---

### Task 1: Aufräumen & Ignore-Regeln

**Files:**
- Create: `.emanoteignore`
- Delete: `build.sh`
- Modify: `.gitattributes` (Zeile `*.tpl linguist-language=HTML` entfernen)
- Modify: `docs/superpowers/specs/2026-10-20-ordnerstruktur-design.md` (Vorlagen-Beschreibung: Titel als H1, nicht im Frontmatter)

**Interfaces:**
- Produces: `_vorlagen/` und `docs/` werden von Emanote ignoriert.

- [ ] **Step 1: `.emanoteignore` anlegen**

```
# Nicht veröffentlichen (FilePattern-Syntax, relativ zum Repo-Root)
_vorlagen/**
docs/**
```

- [ ] **Step 2: `build.sh` löschen** – `git rm build.sh`

- [ ] **Step 3: `.gitattributes`** – Zeile `*.tpl linguist-language=HTML` entfernen, Rest unverändert.

- [ ] **Step 4: Spec korrigieren** – in der Struktur-Tabelle `artikel.md  Frontmatter (title, date, tags) + leere Abschnitte` ersetzen durch `artikel.md  Frontmatter (date, tags), H1-Titel, leere Abschnitte`. (Emanote nimmt den Titel aus der ersten `#`-Überschrift.) Außerdem `Artikel.md  Übersicht: Links zu den vier Kategorieseiten` ersetzen durch `Artikel.md  Übersicht per Query path:Artikel/* (neue Kategorien erscheinen automatisch)`.

- [ ] **Step 5: Prüfen**

Run: `test ! -e build.sh && grep -c tpl .gitattributes; grep -x '_vorlagen/\*\*' .emanoteignore && grep -x 'docs/\*\*' .emanoteignore`
Expected: `0`, dann beide Pattern-Zeilen ausgegeben.

- [ ] **Step 6: Commit** – `chore: Template-Reste entfernen, .emanoteignore anlegen`

---

### Task 2: Seitenstruktur

**Files:**
- Modify: `index.md`, `index.yaml`
- Create: `Artikel.md`, `Artikel/Kanji.md`, `Artikel/Grammatik.md`, `Artikel/Tools.md`, `Artikel/Ressourcen.md`, `Notizen.md`, `Timeline.md`, `Bilder/.gitkeep`

**Interfaces:**
- Produces: Artikelpfad `Artikel/<Kategorie>/<titel>.md`, Notizpfad `Notizen/YYYY-MM-DD-titel.md`.

- [ ] **Step 1: `index.md`** (Satz des Autors bleibt wörtlich)

```markdown
# Kotoba

Hier gibts ab und zu ein paar Beitraege zum Japanisch lernen auf Deutsch.

- [[Artikel]] – ausgearbeitete Beiträge nach Themen
- [[Notizen]] – rohe Gedanken, noch nicht poliert
- [[Timeline]] – alles chronologisch
```

- [ ] **Step 2: `index.yaml`** – unter `page:` ergänzen: `  lang: de` (nach `siteTitle`).

- [ ] **Step 3: `Artikel.md`**

````markdown
# Artikel

```query
path:Artikel/*
```
````

- [ ] **Step 4: Kategorieseiten** – vier Dateien, jeweils `<Kat>` ersetzt durch `Kanji`, `Grammatik`, `Tools`, `Ressourcen`:

`Artikel/<Kat>.md`:
````markdown
# <Kat>

```query {.timeline}
path:Artikel/<Kat>/*
```
````

- [ ] **Step 5: `Notizen.md`**

````markdown
# Notizen

> [!warning] Roh & unpoliert
> Spontane Gedanken, noch nicht ausgearbeitet. Manche werden später zu einem [[Artikel]].

```query {.timeline}
path:Notizen/*
```
````

- [ ] **Step 6: `Timeline.md`**

````markdown
# Timeline

## Artikel

```query {.timeline}
path:Artikel/*/*
```

## Notizen

```query {.timeline}
path:Notizen/*
```
````

- [ ] **Step 7: `Bilder/.gitkeep`** – leere Datei.

- [ ] **Step 8: Prüfen**

Run: `for k in Kanji Grammatik Tools Ressourcen; do grep -qx "path:Artikel/$k/\*" Artikel/$k.md && echo ok-$k; done; grep -x 'path:Artikel/\*/\*' Timeline.md; grep -n 'lang: de' index.yaml; test -f Bilder/.gitkeep && echo bilder-ok`
Expected: `ok-Kanji ok-Grammatik ok-Tools ok-Ressourcen`, die Timeline-Zeile, `lang: de`, `bilder-ok`.

- [ ] **Step 9: Commit** – `feat: Seitenstruktur mit Artikel, Notizen und Timeline`

---

### Task 3: Vorlagen

**Files:**
- Create: `_vorlagen/artikel.md`, `_vorlagen/notiz.md`, `_vorlagen/spickzettel.md`

- [ ] **Step 1: `_vorlagen/artikel.md`**

```markdown
---
date: 2026-01-01
tags: []
---
<!-- Kopieren nach Artikel/<Kategorie>/<titel>.md (Kategorie: Kanji, Grammatik, Tools, Ressourcen). Datum anpassen. -->

# Titel

## Abschnitt

```

- [ ] **Step 2: `_vorlagen/notiz.md`**

```markdown
---
tags: []
---
<!-- Speichern als Notizen/YYYY-MM-DD-titel.md – das Datum wird aus dem Dateinamen gelesen. -->

# Titel

```

- [ ] **Step 3: `_vorlagen/spickzettel.md`**

`````markdown
# Spickzettel

Syntax-Beispiele zum Kopieren. Diese Datei wird nicht veröffentlicht.

## Bilder

Bild in `Bilder/` ablegen (Dateiname ohne Leerzeichen/Umlaute, z. B. `kanji-radikale.png`), dann auf eigener Zeile:

```markdown
![[kanji-radikale.png]]
```

Alternativ mit Pfad und Alt-Text:

```markdown
![Beschreibung](Bilder/kanji-radikale.png)
```

## Links

```markdown
[[Kanji]]                      Link auf eine Seite
[[Kanji|anderer Linktext]]     Link mit eigenem Text
[Jisho](https://jisho.org)     externer Link
```

## Tags

Im Frontmatter:

```yaml
tags: [anki, jlpt/n5]
```

Oder inline im Text: `#anki`

## Hinweisboxen

```markdown
> [!tip] Titel
> Text

> [!warning] Titel
> Text
```

## Tabellen

```markdown
| Kanji | Lesung | Bedeutung |
|-------|--------|-----------|
| 日    | にち    | Tag       |
```

## Furigana

```html
<ruby>漢字<rt>かんじ</rt></ruby>
```
`````

- [ ] **Step 4: Prüfen**

Run: `for f in _vorlagen/artikel.md _vorlagen/notiz.md; do head -1 $f; done; grep -c 'ruby' _vorlagen/spickzettel.md; grep -c 'Leerzeichen' _vorlagen/spickzettel.md`
Expected: zweimal `---` (Frontmatter steht ganz oben), dann Zahlen ≥ 1.

- [ ] **Step 5: Commit** – `feat: Vorlagen für Artikel, Notizen und Spickzettel`

---

### Task 4: README

**Files:**
- Modify (komplett ersetzen): `.github/README.md`

- [ ] **Step 1: Inhalt**

```markdown
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
```

- [ ] **Step 2: Prüfen** – `grep -c emanote-template .github/README.md` → `0`.

- [ ] **Step 3: Commit** – `docs: eigene README`

---

### Task 5: Push & Build prüfen

- [ ] **Step 1:** Vor dem Push Freigabe des Autors einholen (Push veröffentlicht die Seite).
- [ ] **Step 2:** `git push origin master`
- [ ] **Step 3:** Actions-Run beobachten: `gh run watch` (oder Actions-Tab). Expected: "Publish" grün.
- [ ] **Step 4:** Seite prüfen: `/`, `/Artikel`, `/Artikel/Kanji`, `/Notizen`, `/Timeline` erreichbar; `/_vorlagen/spickzettel` und `/docs/...` liefern 404.
