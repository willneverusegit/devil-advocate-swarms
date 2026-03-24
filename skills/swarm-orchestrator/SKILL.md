---
name: swarm-orchestrator
description: Orchestrate adversarial agent swarms with Devil's Advocate debate pattern
triggers:
  - "swarm"
  - "devil's advocate"
  - "adversarial review"
  - "agent debate"
  - "schwarm starten"
---

# Swarm Orchestrator Skill

Startet einen adversariellen Agent-Schwarm mit Scanner → Debate → Fixer Pipeline.

## Modell-Strategie

| Rolle | Modell | Begruendung |
|-------|--------|-------------|
| Team Lead | Opus | Braucht starke Planung + Synthese |
| Scanner | Opus oder Sonnet | Je nach Komplexitaet der Analyse |
| Advocate A/B | **Sonnet** | Argumentation braucht kein Opus, spart ~60% |
| Fixer | Opus | Code-Aenderungen brauchen Praezision |

## Voraussetzung

```json
// .claude/settings.json
{
  "experimental_agent_teams": 1
}
```

## Verwendung

Der Team Lead wird mit dem Prompt aus `prompts/team-lead.md` initialisiert.
Scanner, Advocates und Fixer nutzen ihre jeweiligen Templates aus `prompts/`.

## Ablauf

1. **Scan:** N Scanner-Agenten analysieren parallel
2. **Debate:** 2 Advocate-Agenten (Sonnet) debattieren Funde (max 3 Runden)
3. **Konsens:** Team Lead wertet Debatte aus
4. **Fix:** Fixer-Agenten setzen konsensbasierte Aenderungen um

## Dateisystem-Kommunikation

```
.agent-memory/
├── scratch/
│   ├── scan-assignments.json    # Team Lead → Scanner
│   ├── scanner-1.json           # Scanner → Team Lead
│   ├── scanner-2.json
│   ├── debate-round-1-prosecutor.json
│   ├── debate-round-1-defender.json
│   └── ...
└── consensus/
    ├── result.json              # Finale Entscheidung
    ├── fix-F001.json            # Fix-Dokumentation
    └── fix-F003.json
```
