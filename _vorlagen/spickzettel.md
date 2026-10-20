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
