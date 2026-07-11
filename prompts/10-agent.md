# Agent Phase

Basic building block. One subagent, one task.

## Template

```jsonc
{
  "name": "my-flow",
  "phases": [
    {
      "id": "phase-id",
      "type": "agent",
      "agent": "AGENT_NAME",
      "task": "YOUR INSTRUCTIONS",
      "dependsOn": ["UPSTREAM_ID"],     // optional
      "output": "json",                  // optional — structured output
      "expect": { /* JSON Schema */ },   // optional — validates output
      "retry": { "max": 2 },             // optional — retries on failure
      "timeout": 120000,                 // optional — ms cap
      "final": true                      // optional — result-bearing
    }
  ]
}
```

## Examples

### Structured output with contract
```jsonc
{
  "phases": [
    {
      "id": "list-endpoints",
      "type": "agent",
      "agent": "scout",
      "task": "List all API endpoints in src/routes/. Output ONLY a JSON array of {route, method, file}.",
      "output": "json",
      "expect": {
        "type": "array",
        "items": { "type": "object", "required": ["route", "method", "file"] }
      },
      "retry": { "max": 2 },
      "final": true
    }
  ]
}
```

### With context files
```jsonc
{
  "phases": [
    {
      "id": "analyze-auth",
      "type": "agent",
      "agent": "security-reviewer",
      "task": "Review auth for vulnerabilities. Focus on token storage, refresh logic, session management.",
      "context": ["src/auth/index.ts", "src/auth/middleware.ts"],
      "contextLimit": 12000,
      "final": true
    }
  ]
}
```

## Tips
- Use `output: "json"` + `expect` when downstream needs to parse the output.
- `retry` on structured-output phases makes contract violations retryable.
