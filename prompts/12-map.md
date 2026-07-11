# Map Phase

Fan-out over a JSON array. One subagent per item, `{item}` bound to each element.

## Template

```jsonc
{
  "phases": [
    // 1. Upstream MUST emit a JSON array
    {
      "id": "discover",
      "type": "agent",
      "agent": "scout",
      "task": "Discover items. Output ONLY a JSON array.",
      "output": "json",
      "expect": { "type": "array" }
    },
    // 2. Map over the array
    {
      "id": "process",
      "type": "map",
      "over": "{steps.discover.json}",
      "as": "item",
      "agent": "AGENT_NAME",
      "task": "Do something with {item} or {item.field}",
      "dependsOn": ["discover"],
      "final": true
    }
  ]
}
```

## Example: Audit Each Endpoint

```jsonc
{
  "name": "audit-endpoints",
  "budget": { "maxUSD": 2.00 },
  "phases": [
    {
      "id": "discover",
      "type": "agent",
      "agent": "scout",
      "task": "List all API endpoints in src/routes/. Output ONLY [{\"route\":\"/path\",\"method\":\"GET\",\"file\":\"path\"}].",
      "output": "json",
      "expect": {
        "type": "array",
        "items": { "type": "object", "required": ["route", "method", "file"] }
      }
    },
    {
      "id": "audit",
      "type": "map",
      "over": "{steps.discover.json}",
      "as": "item",
      "agent": "security-reviewer",
      "task": "Audit {item.method} {item.route} (in {item.file}) for: auth, input validation, injection, info leakage.",
      "dependsOn": ["discover"],
      "final": true
    }
  ]
}
```

## Tips
- Upstream MUST emit clean JSON array — tell agent "Output ONLY a JSON array" + use `expect`.
- `{item}` = whole element; `{item.field}` = specific property.
- Always set `budget` — a mis-discovered 500-item array = unbounded spend.
- For known small sets, use `parallel` instead of `map`.
