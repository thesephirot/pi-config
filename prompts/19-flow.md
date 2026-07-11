# Flow Phase

Run a saved or dynamically-generated sub-flow as a single phase.

## Template — Use Saved Flow

```jsonc
{
  "phases": [
    {
      "id": "subtask",
      "type": "flow",
      "use": "saved-flow-name",          // name of a saved flow
      "with": {
        "topic": "{steps.discover.output}",  // pass args to sub-flow
        "dir": "src/api"
      },
      "dependsOn": ["discover"],
      "final": true
    }
  ]
}
```

## Template — Dynamic Sub-Flow (Runtime-Generated)

```jsonc
{
  "phases": [
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Emit a taskflow definition as JSON for implementing the feature. Include phases for explore, implement, and verify.",
      "output": "json"
    },
    {
      "id": "execute",
      "type": "flow",
      "def": "{steps.plan.json}",        // upstream emits flow definition
      "dependsOn": ["plan"],
      "final": true
    }
  ]
}
```

## Example: Discover → Plan → Execute Sub-Flow

```jsonc
{
  "name": "adaptive-workflow",
  "phases": [
    {
      "id": "scout",
      "type": "agent",
      "agent": "scout",
      "task": "Explore the codebase. Summarize architecture, key modules, and tech stack.",
      "final": false
    },
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Based on this exploration, emit a taskflow JSON definition for the migration:\n\n{steps.scout.output}",
      "output": "json",
      "dependsOn": ["scout"]
    },
    {
      "id": "run",
      "type": "flow",
      "def": "{steps.plan.json}",
      "dependsOn": ["plan"],
      "final": true
    }
  ]
}
```

## Tips
- `use` = run a saved flow by name; `def` = run a flow emitted by an upstream phase.
- `with` passes args to the sub-flow (values interpolate).
- Recursion (a flow calling itself) is detected and rejected.
- `def` output is validated (cycles, dangling refs, security caps) before running.
