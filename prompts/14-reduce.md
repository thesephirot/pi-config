# Reduce Phase

Aggregate outputs from multiple upstream phases into one combined result.

## Template

```jsonc
{
  "phases": [
    // ... upstream phases ...
    {
      "id": "report",
      "type": "reduce",
      "from": ["phase-a", "phase-b"],
      "agent": "doc-writer",
      "task": "Combine these into a single report:\n\n{steps.report.output}",
      "dependsOn": ["phase-a", "phase-b"],
      "final": true
    }
  ]
}
```

## Example: Full Discover → Audit → Filter → Report

```jsonc
{
  "name": "full-audit",
  "budget": { "maxUSD": 3.00 },
  "phases": [
    {
      "id": "discover",
      "type": "agent",
      "agent": "scout",
      "task": "List all API endpoints. Output ONLY a JSON array of {route, method, file}.",
      "output": "json"
    },
    {
      "id": "audit",
      "type": "map",
      "over": "{steps.discover.json}",
      "as": "item",
      "agent": "security-reviewer",
      "task": "Audit {item.method} {item.route} in {item.file} for vulnerabilities.",
      "dependsOn": ["discover"]
    },
    {
      "id": "review",
      "type": "gate",
      "agent": "reviewer",
      "dependsOn": ["audit"],
      "task": "Remove false positives. Keep only real issues.\n{steps.audit.output}\n\nVERDICT: PASS or BLOCK"
    },
    {
      "id": "report",
      "type": "reduce",
      "from": ["review"],
      "agent": "doc-writer",
      "task": "Write a final security report with executive summary, findings by severity, and remediation steps.\n\n{steps.review.output}",
      "dependsOn": ["review"],
      "final": true
    }
  ]
}
```

## Tips
- `from` lists which phases to aggregate.
- Common pattern: `map` → `gate` → `reduce`.
- Use a synthesis agent (`doc-writer`, `analyst`) for the reduce step.
