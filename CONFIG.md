# Configuration Reference

This document explains the settings for agent configuration and taskflow orchestration.

## Agent Configuration

Agent definitions live as `.md` files in `.pi/agents/` with YAML frontmatter. The `/agents` command configures which agents are active and which models they use.

### Agent Frontmatter

Each agent `.md` file includes:

```yaml
---
description: "A brief description of what this agent does"
model: "gemma31q4"
tools: ["read", "edit", "bash"]
max_turns: 30
---
```

- **`description`**: How Pi identifies when to select this agent
- **`model`**: The model this agent should use (requires `scopeModels: true` in settings)
- **`tools`**: Which tools this agent can access
- **`max_turns`**: Maximum tool-call rounds before forced conclusion

### `/agents` Command

```bash
/agents
```

Configure agent scope:
- **Project**: Local to your current project (`•`)
- **Global**: Available across all projects (`◦`)
- **Disabled**: Turned off (`✕`)

## Taskflow Configuration

Taskflow (`pi-taskflow`) is the workflow orchestration layer. It replaces the old `subagents.json` configuration.

### Flow-Level Settings

Set these at the top level of a taskflow definition:

- **`concurrency`**: Maximum parallel phases (default: inherited from settings)
- **`budget`**: Cost/tokens caps (`{ maxUSD: 1.50, maxTokens: 2000000 }`)
- **`agentScope`**: Where agents are discovered (`"user"` | `"project"` | `"both"`)
- **`strictInterpolation`**: Fail on unresolved placeholders instead of silent empty strings

### Per-Phase Settings

- **`retry`**: Auto-retry on failure (`{ max: 3, backoffMs: 1000, factor: 2 }`)
- **`timeout`**: Max ms per phase (>= 1000)
- **`expect`**: JSON output contract — validates output shape, retryable on violation
- **`optional`**: Fail-soft — downstream sees empty output instead of aborting the run
- **`cache`**: Reuse policy (`"run-only"` | `"cross-run"` | `"off"`)
- **`when`**: Conditional guard — skip phase unless expression is truthy
- **`join`**: `"all"` (default) or `"any"` — wait for all deps or just one

### Cross-Run Caching

Enable `incremental: true` on a flow or `cache: "cross-run"` on phases to reuse results across runs. Changes to source files only re-run affected phases.

```
/tf ir <name>      # show phase fingerprints
/tf why-stale <runId> [phaseId]  # find which phases changed
/tf recompute <runId> <phaseId>  # re-run only affected phases
```

### Settings File

Pi's `settings.json` (in `.pi/`) controls global defaults that taskflow flows inherit:

- **`scopeModels`**: When `true`, agents use their own model from `.md` frontmatter instead of inheriting the host session's model
- **`toolDescriptionMode`**: Tool documentation verbosity (`"full"` | `"compact"` | `"name-only"`)
- **`modelRoles`**: Default model assignments for taskflow agents (executor, scout, planner, etc.)

### Example Taskflow Definitions

#### Simple Chain
```json
{
  "name": "review-and-fix",
  "phases": [
    { "id": "review", "type": "agent", "agent": "researcher",
      "task": "Review the codebase for issues." },
    { "id": "fix", "type": "agent", "agent": "coder",
      "dependsOn": ["review"],
      "task": "Fix the issues identified:\n{steps.review.output}" }
  ]
}
```

#### Production Audit (Fan-Out + Gate + Reduce)
```json
{
  "name": "audit-endpoints",
  "concurrency": 8,
  "budget": { "maxUSD": 2.00 },
  "phases": [
    { "id": "discover", "type": "agent", "agent": "scout",
      "task": "List all API endpoints. Output ONLY a JSON array.",
      "output": "json" },
    { "id": "audit", "type": "map", "over": "{steps.discover.json}",
      "agent": "analyst",
      "task": "Audit {item.route} ({item.file}) for missing auth." },
    { "id": "review", "type": "gate", "dependsOn": ["audit"],
      "agent": "reviewer",
      "task": "Review findings. Remove false positives. VERDICT: PASS or BLOCK." },
    { "id": "report", "type": "reduce", "from": ["review"],
      "dependsOn": ["review"], "agent": "doc-writer",
      "task": "Write a final report:\n{steps.review.output}",
      "final": true }
  ]
}
```
