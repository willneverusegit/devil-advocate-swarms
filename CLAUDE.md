# Devil's Advocate Swarms

## Plugin-Info
Dieses Projekt ist ein eigenstaendiges Claude Code Plugin. Es kann in jedem Projekt
via `claude plugin install <pfad>` installiert und ueber `/swarm` aufgerufen werden.
Bestehende direkte Zugriffe (z.B. ueber Pfade in `prompts/`, `scripts/`) funktionieren weiterhin.

## Was ist das
Adversarielle Agent-Teams fuer Claude Code. Statt linearer Sub-Agenten wird ein hierarchischer Schwarm gespawnt, der durch Debatte (Devil's Advocate Pattern) zu besseren Ergebnissen kommt.

## Architektur
- **Team Lead:** Spawnt Scanner-, Debate- und Fixer-Agenten
- **Scanner-Agenten:** Parallele Analyse (z.B. Security-Scan, Code-Review)
- **Devil's Advocate Paar:** Zwei Agenten debattieren Funde (Teufel 1 vs. Teufel 2)
- **Fixer-Agenten:** Werden erst nach Konsens der Debatte erstellt
- **Kommunikation:** Geteiltes Scratch Pad (Dateisystem)

## Use Cases
1. **Security Audits** — 10 Scanner parallel, Debate filtert False Positives, Fixer patcht
2. **Architektur-Reviews** — Agenten debattieren Design-Entscheidungen vor Implementierung
3. **Design/Copywriting** — "Minimalistisch" vs. "Warm" Agenten finden Konsens
4. **Integration mit Ralph-Wiggum-Loop** — Phase 1 (Planung) und Phase 3 (Judge/Review)

## Tech Stack
- **Claude Code CLI** mit `experimental_agent_teams`
- **Kommunikation:** Dateisystem-basiert (Scratch Pad als JSON/Markdown)
- **Plattform:** Windows + Git Bash / WSL

## Voraussetzungen
- `"experimental_agent_teams": 1` in `.claude/settings.json`
- Ausreichend API-Budget (jeder Subagent = eigenes Kontextfenster)
- Strukturierte Prompt-Templates fuer Scanner, Advocate und Fixer Rollen

## Konventionen
- **Plugin-Manifest:** `plugin.json`
- **Plugin-Agents:** `agents/` (team-lead, scanner, advocate, fixer)
- **Slash-Command:** `commands/swarm.md` → `/swarm`
- Prompt-Templates in `prompts/` (weiterhin fuer Script-Modus)
- Skills in `skills/{name}/SKILL.md`
- Beispiel-Konfigurationen in `examples/`
- Scratch Pad Dateien in `.agent-memory/scratch/` (im Zielprojekt)
- Konsens-Ergebnisse in `.agent-memory/consensus/` (im Zielprojekt)
- Jede Debatte wird geloggt in `.agent-memory/debates/` (im Zielprojekt)

## Research-Workflow (Standard)
Web-Recherche IMMER ueber die Research-Pipeline ausfuehren:
1. **Perplexity** (Suche + Links) → 2. **NotebookLM** (Ingest + RAG) → 3. **Claude** (liest nur Ergebnis)
Ergebnisse in `research/<topic>-<date>.md` speichern. Siehe `skills/research-pipeline/SKILL.md`.

## Kosten-Bewusstsein
- Jeder Subagent verbraucht eigene Tokens — Schwarm von 10 Scannern + 2 Advocates = ~12x Einzelagent
- Immer mit kleinem Schwarm (2-3 Agenten) starten und skalieren
- Scanner-Ergebnisse cachen um redundante Analysen zu vermeiden

## Bekannte Einschraenkungen
- `experimental_agent_teams` ist ein experimentelles Feature — kann sich aendern
- Keine garantierte Konvergenz der Debatte — Timeout/Max-Runden noetig
- Scratch Pad kann bei vielen Agenten Race Conditions haben
