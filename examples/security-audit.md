# Beispiel: Security Audit Workflow

## Szenario
Du willst ein Node.js-Projekt auf Security-Schwachstellen pruefen.

## Konfiguration

```json
// .claude/settings.json
{
  "experimental_agent_teams": 1
}
```

## Prompt an Team Lead

```
Fuehre ein Security Audit fuer dieses Node.js-Projekt durch.

Fokus:
- Command Injection (child_process, exec, spawn)
- Path Traversal (fs-Operationen mit User-Input)
- SQL/NoSQL Injection
- XSS in Templates/Responses
- Unsichere Dependencies (package.json)

Nutze 3 Scanner:
1. Scanner fuer Code-Analyse (Quellcode durchsuchen)
2. Scanner fuer Dependency-Analyse (package.json + lock)
3. Scanner fuer Config-Analyse (.env, Secrets, Permissions)

Debatte mit Sonnet-Advocates, Fixes nur fuer konsensbasierte Funde.
```

## Erwarteter Ablauf

```
Team Lead (Opus)
  ├── Scanner 1: Code-Analyse        → scanner-1.json
  ├── Scanner 2: Dependencies         → scanner-2.json
  └── Scanner 3: Config               → scanner-3.json
       │
       ▼ Alle Funde gesammelt
  ├── Advocate A (Sonnet): "Funde sind echt"
  └── Advocate B (Sonnet): "Funde sind False Positives"
       │
       ▼ Konsens nach 1-3 Runden
  └── Fixer: Patcht akzeptierte Funde
```

## Kosten-Schaetzung
- 3 Scanner + 2 Advocates (je 2-3 Runden) + 1-2 Fixer
- ~8-10 Agent-Kontextfenster
- Bei Sonnet-Advocates ca. 40-60% guenstiger als reines Opus
