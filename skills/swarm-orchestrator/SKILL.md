---
name: swarm-orchestrator
description: >
  Orchestrate adversarial agent swarms with Devil's Advocate debate pattern:
  Scanner agents analyze in parallel, two Advocates debate findings for up
  to 3 rounds, a Team Lead synthesizes consensus, and Fixer agents apply
  the accepted changes.
  Trigger phrases: "adversarial swarm", "devil's advocate", "adversarial review",
  "agent debate", "swarm review", "start swarm", "schwarm starten",
  "teufels advokat", "adversarialer review".
user_invocable: true
metadata:
  author: devil-advocate-swarms
  version: '0.1.1'
  part-of: devil-advocate-swarms
  layer: orchestration
depends-on:
  - agents/team-lead.md (swarm-team-lead)
  - agents/scanner.md (swarm-scanner)
  - agents/advocate.md (swarm-advocate)
  - agents/fixer.md (swarm-fixer)
  - experimental_agent_teams setting in .claude/settings.json
---

# Swarm Orchestrator Skill

Startet einen adversariellen Agent-Schwarm mit Scanner → Debate → Fixer Pipeline.

## Modell-Strategie

| Rolle | Modell | Begruendung |
|-------|--------|-------------|
| Team Lead | Opus (`claude-opus-4-7`) | Braucht starke Planung + Synthese |
| Scanner | Opus oder Sonnet (`claude-sonnet-4-6`) | Je nach Komplexitaet der Analyse |
| Advocate A/B | **Sonnet** (`claude-sonnet-4-6`) | Argumentation braucht kein Opus, spart ~60% |
| Fixer | Opus (`claude-opus-4-7`) | Code-Aenderungen brauchen Praezision |

## Voraussetzung

```json
// .claude/settings.json
{
  "experimental_agent_teams": 1
}
```

## Verwendung

Der Team Lead wird mit dem Agent-Template `agents/team-lead.md` initialisiert.
Scanner, Advocates und Fixer nutzen ihre jeweiligen Agent-Templates aus `agents/`.

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

## Fehlerbehandlung

### Scanner-Agent schlaegt fehl / schreibt keine Ausgabe

**Problem:** Ein oder mehrere Scanner schreiben keine Ergebnis-Datei in `.agent-memory/scratch/scanner-{n}.json`.

**Vorgehen:**
```
→ Nach 120s Timeout: fehlende Scanner-Dateien als nicht verfuegbar markieren
→ Minimum 1 Scanner muss Ergebnis liefern — sonst Abbruch mit Fehlermeldung
→ Fehlgeschlagene Scanner werden im Konsens-Ergebnis als "scanner_skipped" vermerkt
→ Team Lead fährt mit verfuegbaren Ergebnissen fort
```

### Debatte erreicht keinen Konsens (max Runden erreicht)

**Problem:** Nach 3 Debate-Runden ist prosecutor und defender weiterhin uneinig.

**Vorgehen:**
```
→ Konservative Entscheidung: Alle strittigen Funde BEHALTEN (lieber false-positive als miss)
→ Konsens-Ergebnis mit "consensus_method": "conservative_fallback" markieren
→ Begruendung fuer jeden strittigen Fund dokumentieren
```

### Fixer-Agent schlaegt fehl

**Problem:** `swarm-fixer` Agent kann eine Aenderung nicht umsetzen (Datei nicht schreibbar, Konflikt, etc.).

**Vorgehen:**
```
→ Fix als "fix_status": "failed" in .agent-memory/consensus/fix-{id}.json dokumentieren
→ Fehlermeldung und Ursache festhalten
→ Naechsten Fix fortsetzen — ein fehlgeschlagener Fix stoppt nicht den gesamten Schwarm
→ Am Ende: Summary aller fehlgeschlagenen Fixes ausgeben
```

### Verzeichnis-Erstellung schlaegt fehl

**Problem:** `.agent-memory/scratch/`, `.agent-memory/consensus/` oder `.agent-memory/debates/` koennen nicht erstellt werden.

**Vorgehen:**
```
→ Berechtigungsfehler: Nutzer auffordern, Schreibrechte zu pruefen
→ Pfad nicht existiert: Bash-Fallback `mkdir -p .agent-memory/{scratch,consensus,debates}`
→ Schwarm stoppt, bis Verzeichnisse verfuegbar sind
```
