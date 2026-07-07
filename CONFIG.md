# Configuration Reference

This document explains the settings for agent configuration and taskflow orchestration.

## Agent Configuration

Agent definitions live as `.md` files in `.pi/agents/` with YAML frontmatter. The `/agents` command configures which agents are active and which models they use.

### Agent Frontmatter

Each agent `.md` file includes:

```yaml
---
description: "A brief description of what this agent does"
display_name: my-agent
model: "gemma31q4:thinking"
tools: read, edit, bash
max_turns: 30
thinking: high
prompt_mode: replace
---
```

- **`description`**: How Pi identifies when to select this agent
- **`display_name`**: Human-readable name for the agent (e.g., `orchestrator`, `coder`). If omitted, Pi infers it from the filename.
- **`model`**: The model this agent should use (requires `scopeModels: true` in settings). Supports `:thinking`/`:nothinking` suffixes for models with filter overrides.
- **`tools`**: Which tools this agent can access (comma-separated list)
- **`max_turns`**: Maximum tool-call rounds before forced conclusion
- **`thinking`**: Thinking mode intensity (`low` | `medium` | `high`). Controls how much the model reasons before responding.
- **`prompt_mode`**: System prompt handling. `replace` overrides the default Pi system prompt entirely with the agent's own instructions.
- **`enabled`**: Set to `false` to disable an agent (useful for templates or unused agents)

### Model Aliases (`:thinking` / `:nothinking`)

Models configured with `filters.setParamsByID` in llama-swap support suffixed variants:

- `model_id:thinking` — enables thinking mode with custom parameters (higher temperature, reasoning budget)
- `model_id:nothinking` — disables thinking mode with standard parameters (low temperature)

Models in this project that support `:thinking`/`:nothinking`:
- `gemma31q4`
- `gemma26`
- `qwen36-a3b-q6`
- `qwen36-27b-mtp-q3`

When `scopeModels: true` is set in Pi's settings, agents can use these suffixed models directly (e.g., `model: "gemma31q4:thinking"`).

### Routing Groups

The llama-swap `routing` configuration defines model groups for load management:

- **`swap`**: When `false`, all members stay loaded simultaneously. When `true`, only one member is loaded at a time (others are unloaded when switching).
- **`exclusive`**: When `false`, requesting a member loads it without unloading others. When `true`, requesting a member unloads all others in the group.
- **`members`**: List of model IDs belonging to the group.

This project configures a `clever` group containing `qwen36-27b-mtp-q3` and `gemma26`, both kept loaded (`swap: false`, `exclusive: false`).

### Llama-Swap Top-Level Settings

- **`includeAliasesInList`**: When `true`, shows filter-generated aliases (e.g., `gemma31q4:thinking`) in the model list.
- **`sendLoadingState`**: When `true`, injects loading status updates into the reasoning (thinking) stream, so the user sees progress while models load.

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
    { "id": "discover", "type": "agent", "agent": "explore",
      "task": "List all API endpoints. Output ONLY a JSON array.",
      "output": "json" },
    { "id": "audit", "type": "map", "over": "{steps.discover.json}",
      "agent": "researcher",
      "task": "Audit {item.route} ({item.file}) for missing auth." },
    { "id": "review", "type": "gate", "dependsOn": ["audit"],
      "agent": "architect",
      "task": "Review findings. Remove false positives. VERDICT: PASS or BLOCK." },
    { "id": "report", "type": "reduce", "from": ["review"],
      "dependsOn": ["review"], "agent": "researcher",
      "task": "Write a final report:\n{steps.review.output}",
      "final": true }
  ]
}
```
