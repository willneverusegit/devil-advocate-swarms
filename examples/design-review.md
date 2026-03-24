# Beispiel: Architektur-Review Workflow

## Szenario
Vor einer groesseren Implementierung sollen verschiedene Design-Ansaetze
durch adversarielle Debatte evaluiert werden.

## Prompt an Team Lead

```
Wir wollen das Auth-System von Session-basiert auf JWT umstellen.
Bewerte die Architektur-Entscheidung bevor wir implementieren.

Nutze 2 Scanner:
1. Analysiere die aktuelle Session-Implementierung (Staerken/Schwaechen)
2. Analysiere JWT-Alternativen im Kontext unseres Stacks

Dann Debatte:
- Advocate A argumentiert FUER die JWT-Migration
- Advocate B argumentiert GEGEN die JWT-Migration (Session behalten)

Ergebnis: Klare Empfehlung mit Begruendung.
```

## Erwarteter Ablauf

```
Team Lead (Opus)
  ├── Scanner 1: Ist-Analyse (Sessions)   → scanner-1.json
  └── Scanner 2: Soll-Analyse (JWT)       → scanner-2.json
       │
       ▼
  ├── Advocate A (Sonnet): "JWT ist besser weil..."
  └── Advocate B (Sonnet): "Sessions behalten weil..."
       │
       ▼ Konsens
  └── Team Lead: Architektur-Empfehlung → consensus/result.json
```

## Besonderheit
Hier wird KEIN Fixer-Agent gebraucht — das Ergebnis ist eine Entscheidung,
keine Code-Aenderung. Der Team Lead fasst die Debatte zusammen und gibt
eine begruendete Empfehlung ab.
