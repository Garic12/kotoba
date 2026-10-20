# Kotoba – Ordnerstruktur & Aufräumen

Datum: 2026-10-20

## Ziel

Die aus dem Emanote-Template entstandene Seite aufräumen und ein leeres,
sauberes Gerüst nach dem Vorbild von https://morg.systems/ anlegen:
kuratierte Artikel nach Kategorien, rohe Notizen, eine Timeline.

**Kein Inhalt** – nur Struktur, Übersichtsseiten mit automatischen Listen und
Vorlagen zum Kopieren. Artikeltexte schreibt der Autor selbst.

## Rahmenbedingungen

- Generator: Emanote (via `flake.nix`), Build & Deploy ausschließlich über
  GitHub Actions (`.github/workflows/publish.yaml`, Branch `master`).
- Sprache der Seite: Deutsch.
- Kategorien zum Start: Kanji, Grammatik, Tools, Ressourcen.

## Struktur

```
index.md              Startseite: Intro + Links zu Artikel / Notizen / Timeline
index.yaml            zusätzlich page.lang: de
Artikel.md            Übersicht per Query path:Artikel/* (neue Kategorien erscheinen automatisch)
Artikel/
  Kanji.md            Kategorieseite, Query path:Artikel/Kanji/*
  Grammatik.md        Query path:Artikel/Grammatik/*
  Tools.md            Query path:Artikel/Tools/*
  Ressourcen.md       Query path:Artikel/Ressourcen/*
Notizen.md            Hinweis "roh & unpoliert" + Timeline-Query path:Notizen/*
Timeline.md           Zwei Timeline-Queries: path:Artikel/*/* und path:Notizen/*
Bilder/               Bildablage (mit .gitkeep, damit der Ordner existiert)
_vorlagen/            nicht veröffentlicht
  artikel.md          Frontmatter (date, tags), H1-Titel, leere Abschnitte
  notiz.md            Frontmatter + leerer Text; Dateiname YYYY-MM-DD-titel.md
  spickzettel.md      Syntax-Beispiele (siehe unten)
.emanoteignore        _vorlagen/** und docs/**
```

Artikel landen in `Artikel/<Kategorie>/<titel>.md`; die Unterordner entstehen
mit dem ersten Artikel. Kategorieseiten sind Emanote-"Folder Notes"
(`Artikel/Kanji.md` gehört zum Ordner `Artikel/Kanji/`).

Timeline-Queries nutzen die Syntax ```` ```query {.timeline} ```` und sortieren
nach `date` (Frontmatter oder `YYYY-MM-DD`-Präfix im Dateinamen).

## Spickzettel-Inhalte

Nur Syntax-Beispiele, kein Lerninhalt:

- Bild einbetten: `![[bild.png]]` (Pfad egal, Ablage in `Bilder/`) und `![](Bilder/bild.png)`
- Interne Links: `[[Kanji]]`, `[[Kanji|anderer Text]]`
- Tags im Frontmatter und inline
- Hinweisboxen: `> [!tip]`, `> [!warning]`
- Tabellen
- Furigana: `<ruby>漢字<rt>かんじ</rt></ruby>`

## Aufräumen

- `.github/README.md`: durch kurze deutsche README ersetzen (Beitrag anlegen,
  Vorlagen, Bilder, Deployment).
- `build.sh`: löschen (Build läuft über GitHub Actions).
- `.gitattributes`: Zeile `*.tpl …` entfernen.
- Unverändert: `flake.nix`, `flake.lock`, beide Workflows, `.envrc`, `.gitignore`.
- `LICENSE` (CC0) bleibt unangetastet – Entscheidung des Autors.

## Prüfung

Kein lokaler Build. Nach dem Push: GitHub-Actions-Run "Publish" muss grün sein,
und auf https://garic12.github.io/kotoba/ müssen Startseite, Artikel mit vier
Kategorien, Notizen und Timeline erreichbar sein; `_vorlagen` und `docs` dürfen
nicht auftauchen.
