# Devil's Advocate Swarms

Adversarielle Agent-Teams fuer Claude Code — bessere Ergebnisse durch strukturierte Debatte.

## Idee

Statt einen Agenten linear arbeiten zu lassen, spawnt ein "Team Lead" mehrere
Sub-Agenten mit unterschiedlichen Rollen. Zwei "Devil's Advocate"-Agenten
debattieren die Ergebnisse — erst bei Konsens wird gehandelt.

```
┌──────────────────────────────────────────────────────┐
│  Team Lead (Orchestrator)                            │
│    │                                                 │
│    ├── Scanner 1 ──┐                                 │
│    ├── Scanner 2 ──┤                                 │
│    ├── Scanner N ──┤                                 │
│    │               ▼                                 │
│    │         ┌─────────────┐                         │
│    │         │ Scratch Pad │ (geteilte Ergebnisse)   │
│    │         └──────┬──────┘                         │
│    │                ▼                                 │
│    │    ┌───────────────────────┐                     │
│    │    │  Devil's Advocate 1   │◄──► Debatte         │
│    │    │  Devil's Advocate 2   │                     │
│    │    └───────────┬───────────┘                     │
│    │                ▼                                 │
│    │          Konsens erreicht?                       │
│    │           ja │    │ nein                         │
│    │              ▼    └──► weitere Runde             │
│    │         Fixer-Agent                              │
│    │              │                                   │
│    │              ▼                                   │
│    │         Code-Aenderung                           │
└──────────────────────────────────────────────────────┘
```

## Projektstruktur

```
devil-advocate-swarms/
├── CLAUDE.md                # Projekt-Instruktionen
├── README.md                # Diese Datei
├── prompts/
│   ├── team-lead.md         # System-Prompt fuer den Orchestrator
│   ├── scanner.md           # Template fuer Scanner-Agenten
│   ├── advocate.md          # Template fuer Devil's Advocate Rolle
│   └── fixer.md             # Template fuer Fixer-Agenten
├── examples/
│   ├── security-audit.md    # Beispiel: Security-Audit Workflow
│   └── design-review.md     # Beispiel: Architektur-Review Workflow
├── skills/
│   └── swarm-orchestrator/
│       └── SKILL.md
└── .agent-memory/
    ├── scratch/             # Geteiltes Scratch Pad
    ├── consensus/           # Konsens-Ergebnisse
    └── debates/             # Debatte-Logs
```

## Aktivierung

```json
// .claude/settings.json
{
  "experimental_agent_teams": 1
}
```

## Use Cases

| Use Case | Scanner | Advocate-Thema | Fixer |
|----------|---------|---------------|-------|
| Security Audit | 5-10 Vulnerability Scanner | "Ist das ein echtes Risiko?" | Patch-Agent |
| Architektur Review | 2-3 Design Analyzer | "Microservice vs. Monolith?" | Refactor-Agent |
| Copywriting | 2 Stil-Varianten | "Minimalistisch vs. Warm?" | Final-Writer |
| Code Quality | 3 Linter/Reviewer | "False Positive oder Bug?" | Bugfix-Agent |

## Kosten

Jeder Subagent = eigenes Kontextfenster. Ein Schwarm von 10 Scannern + 2 Advocates
verbraucht ca. 12x so viele Tokens wie ein Einzelagent. Start klein (2-3), dann skalieren.

## Status

**Phase: Planung** — Projektstruktur angelegt, Use Cases definiert. Naechster Schritt: Prompt-Templates fuer Scanner und Advocate Rollen.

## Quellen

- Nick Saraev: "CLAUDE CODE FULL COURSE 4 HOURS" (Security Issues + paralleles Design)
- NotebookLM Research: "Agentic AI & Self-Improving Workflows"
- NotebookLM Notiz: "Architektur und Steuerung von Adversarial Agent Swarms"
