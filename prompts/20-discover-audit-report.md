# Archetype: Discover → Audit → Report

The classic fan-out pattern. Discover items, audit each in parallel, filter false positives, produce final report.

## Template

```jsonc
{
  "name": "discover-audit-report",
  "budget": { "maxUSD": 3.00 },
  "phases": [
    // 1. DISCOVER — emit JSON array of items
    {
      "id": "discover",
      "type": "agent",
      "agent": "scout",
      "task": "YOUR_DISCOVERY_TASK. Output ONLY a JSON array.",
      "output": "json",
      "expect": { "type": "array", "items": { "type": "object", "required": ["YOUR_KEYS"] } },
      "retry": { "max": 2 }
    },
    // 2. MAP — audit each item
    {
      "id": "audit",
      "type": "map",
      "over": "{steps.discover.json}",
      "as": "item",
      "agent": "security-reviewer",
      "task": "YOUR_AUDIT_TASK using {item.field}",
      "dependsOn": ["discover"]
    },
    // 3. GATE — filter false positives
    {
      "id": "review",
      "type": "gate",
      "agent": "reviewer",
      "dependsOn": ["audit"],
      "output": "json",
      "expect": {
        "type": "object",
        "properties": { "verdict": { "enum": ["pass", "block"] } },
        "required": ["verdict"]
      },
      "task": "Remove false positives. Keep only real issues.\n{steps.audit.output}\n\nRespond {\"verdict\":\"pass\"|\"block\"}"
    },
    // 4. REDUCE — final report
    {
      "id": "report",
      "type": "reduce",
      "from": ["review"],
      "agent": "doc-writer",
      "task": "Write a final report with executive summary, findings by severity, and remediation.\n\n{steps.review.output}",
      "dependsOn": ["review"],
      "final": true
    }
  ]
}
```

## Concrete Example: API Endpoint Security Audit

```jsonc
{
  "name": "api-security-audit",
  "budget": { "maxUSD": 3.00 },
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
      "task": "Audit {item.method} {item.route} in {item.file}: auth, input validation, injection, info leakage.",
      "dependsOn": ["discover"]
    },
    {
      "id": "review",
      "type": "gate",
      "agent": "reviewer",
      "dependsOn": ["audit"],
      "task": "Remove false positives. Keep real issues only.\n{steps.audit.output}\n\nVERDICT: PASS or BLOCK"
    },
    {
      "id": "report",
      "type": "reduce",
      "from": ["review"],
      "agent": "doc-writer",
      "task": "Write a security audit report: executive summary, findings by severity, remediation.\n\n{steps.review.output}",
      "dependsOn": ["review"],
      "final": true
    }
  ]
}
```

## Tips
- Always set `budget` on fan-out flows.
- Pin upstream output shape with `expect` so `map` items are reliable.
- Gate filters noise before the final report.
