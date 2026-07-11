# Parallel Phase

Fixed set of branches, run concurrently. Use when you know the tasks upfront.

## Template

```jsonc
{
  "phases": [
    {
      "id": "my-parallel",
      "type": "parallel",
      "branches": [
        { "task": "BRANCH_1_TASK", "agent": "AGENT_1" },
        { "task": "BRANCH_2_TASK", "agent": "AGENT_2" }
      ],
      "dependsOn": ["UPSTREAM_ID"],
      "final": true
    }
  ]
}
```

## Examples

```jsonc
// Multi-angle review
{
  "phases": [
    {
      "id": "explore",
      "type": "agent",
      "agent": "scout",
      "task": "Explore the codebase. List key files and their purposes."
    },
    {
      "id": "reviews",
      "type": "parallel",
      "branches": [
        { "task": "Review for security (injection, auth, secrets, XSS).", "agent": "security-reviewer" },
        { "task": "Review for architecture (coupling, SOLID, error handling).", "agent": "reviewer" },
        { "task": "Review for backend risks (DB migrations, concurrency, API contracts).", "agent": "risk-reviewer" }
      ],
      "dependsOn": ["explore"],
      "final": true
    }
  ]
}
```

## Tips
- Use for a known, small set of branches (2–6).
- For dynamic fan-out over a discovered list, use `map` instead.
- All branches share the same `dependsOn`.
