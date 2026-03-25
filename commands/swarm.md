---
name: swarm
description: "Start an adversarial agent swarm with Scanner -> Debate -> Consensus -> Fix pipeline"
arguments:
  - name: goal
    description: "What to analyze (e.g. 'Security audit', 'Code quality review', 'Architecture review')"
    required: true
  - name: target
    description: "Directory to analyze (default: current working directory)"
    required: false
  - name: scanners
    description: "Number of scanner agents (default: 3, max: 5)"
    required: false
  - name: no-fix
    description: "Skip fix phase, output consensus only (default: false)"
    required: false
---

# /swarm — Adversarial Agent Swarm

Starte einen adversariellen Schwarm fuer: **$ARGUMENTS.goal**

## Konfiguration
- **Zielverzeichnis:** ${ARGUMENTS.target:-aktuelles Verzeichnis}
- **Scanner-Anzahl:** ${ARGUMENTS.scanners:-3}
- **Fix-Phase:** ${ARGUMENTS.no-fix:-aktiv}

## Ausfuehrung

Es gibt zwei Wege diesen Schwarm auszufuehren:

### Option A: Script-basiert (Multi-Model mit Codex + Sonnet + Opus)
Fuehre das Orchestrator-Script aus:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/orchestrator.sh \
  --target "${ARGUMENTS.target:-.}" \
  --goal "${ARGUMENTS.goal}" \
  --scanners ${ARGUMENTS.scanners:-3} \
  ${ARGUMENTS.no-fix:+--no-fix}
```

### Option B: Agent-basiert (rein Claude Code Agents)
Spawne den `swarm-team-lead` Agent mit dieser Aufgabe:
- Ziel: $ARGUMENTS.goal
- Verzeichnis: ${ARGUMENTS.target:-aktuelles Verzeichnis}
- Scanner: ${ARGUMENTS.scanners:-3}

Der Team Lead orchestriert dann automatisch Scanner, Advocates und Fixer.

## Nach Abschluss
- Konsens-Ergebnis: `.agent-memory/consensus/result.json`
- Debatten-Log: `.agent-memory/debates/`
- Fixes: `.agent-memory/consensus/fix-*.json`
