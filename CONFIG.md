# Subagents Configuration Reference

This document explains the settings in `subagents.json`, which controls how Pi manages its subagent fleet.

## Settings Reference

### `maxConcurrent` — Maximum Parallel Subagents
- **Default**: `2`
- Controls how many subagents can run simultaneously. Higher values speed up parallel work (e.g., auditing multiple files at once) but consume more memory and context window. Lower values are safer for limited GPU resources.

### `defaultMaxTurns` — Default Conversation Length
- **Default**: `0` (unlimited)
- Maximum number of tool-call rounds a subagent can make before being forced to conclude. Set to `0` to allow unlimited turns, or a positive integer to cap execution time. Individual agents can override this in their `.md` frontmatter (e.g., `max_turns: 30`).

### `graceTurns` — Grace Period Before Forced Completion
- **Default**: `5`
- After a subagent reaches its turn limit, it gets this many additional "grace" turns to finish its work and produce output. Prevents abrupt termination mid-task.

### `defaultJoinMode` — Result Merge Strategy
- **Default**: `"smart"`
- Controls how results from parallel subagents are combined:
  - `"smart"` — automatically picks the best merge strategy based on output type
  - `"concat"` — simple concatenation of all outputs
  - `"last"` — uses only the last agent's output
- Affects `taskflow` parallel phases and ad-hoc parallel subagent spawns.

### `schedulingEnabled` — Agent Execution Scheduler
- **Default**: `true`
- When enabled, Pi schedules subagent execution based on priority, resource availability, and dependencies. Disable only if you want purely FIFO execution.

### `scopeModels` — Per-Agent Model Scoping
- **Default**: `false`
- When `true`, each agent uses the model specified in its `.md` frontmatter (`model:` field). When `false`, all agents inherit the host session's active model. Enable this to give different agents different models (e.g., a cheap model for search, a strong model for architecture).

### `toolDescriptionMode` — Tool Documentation Verbosity
- **Default**: `"full"`
- Controls how much detail about available tools is included in the agent's system prompt:
  - `"full"` — complete tool descriptions with all parameters
  - `"compact"` — tool name and one-line summary
  - `"name-only"` — just the tool names (saves tokens, risks misuse)
- Use `"compact"` or `"name-only"` to reduce context usage for agents that only need a few tools.

### `fleetView` — Subagent Fleet Dashboard
- **Default**: `true`
- When enabled, shows a real-time dashboard of all running subagents in the Pi TUI (`/agents` command). Disable to reduce UI overhead.

### `widgetMode` — Dashboard Display Style
- **Default**: `"background"`
- Controls how the subagent fleet status is displayed:
  - `"background"` — minimal status bar (doesn't block main view)
  - `"inline"` — embedded in the conversation stream
  - `"popup"` — separate panel that can be toggled

## Example Configurations

### Resource-Constrained (Small GPU)
```json
{
  "maxConcurrent": 1,
  "defaultMaxTurns": 20,
  "graceTurns": 3,
  "defaultJoinMode": "smart",
  "schedulingEnabled": true,
  "scopeModels": false,
  "disableDefaultAgents": false,
  "toolDescriptionMode": "compact",
  "fleetView": true,
  "widgetMode": "background"
}
```

### Performance-Oriented (Large GPU, Multi-Model)
```json
{
  "maxConcurrent": 4,
  "defaultMaxTurns": 0,
  "graceTurns": 5,
  "defaultJoinMode": "smart",
  "schedulingEnabled": true,
  "scopeModels": true,
  "disableDefaultAgents": false,
  "toolDescriptionMode": "full",
  "fleetView": true,
  "widgetMode": "inline"
}
```
