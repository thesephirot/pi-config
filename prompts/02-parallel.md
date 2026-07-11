# Shorthand: Parallel Tasks

Run several independent tasks concurrently. Outputs merged.

## Template

```jsonc
{
  "tasks": [
    { "task": "TASK_1", "agent": "AGENT_1" },
    { "task": "TASK_2", "agent": "AGENT_2" }
  ]
}
```

## Examples

```jsonc
// Parallel audit
{
  "tasks": [
    { "task": "Audit auth logic in src/auth/ for vulnerabilities (injection, broken auth, session issues).", "agent": "security-reviewer" },
    { "task": "Audit input validation in src/api/ endpoints. Check sanitization, type coercion, edge cases.", "agent": "analyst" },
    { "task": "Review error handling in src/middleware/. Find uncaught exceptions and missing fallbacks.", "agent": "reviewer" }
  ]
}

// Shared context across all branches
{
  "tasks": [
    { "task": "Review for security issues.", "agent": "security-reviewer" },
    { "task": "Review for code quality and architecture.", "agent": "reviewer" }
  ],
  "context": ["src/api/routes.ts", "src/api/middleware.ts"],
  "contextLimit": 10000
}
```

## Tips
- All tasks run concurrently — use `chain` if tasks depend on each other.
- In parallel mode, all branches SHARE the union of all `context` files.
- For fan-out over a dynamic discovered list, use `map` phase instead.
