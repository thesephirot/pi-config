# Approval Phase

Human-in-the-loop pause. Run stops for you to **Approve**, **Reject**, or **Edit**.

## Outcomes

| Action | Output | Flow |
|--------|--------|------|
| Approve | `(approve)` | Continues |
| Reject | — | Halts |
| Edit | Your typed note | Continues, note as `{steps.id.output}` |

## Template

```jsonc
{
  "phases": [
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Create a detailed plan for: YOUR_TASK"
    },
    {
      "id": "approve",
      "type": "approval",
      "dependsOn": ["plan"],
      "task": "Review this plan:\n\n{steps.plan.output}"
    },
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor",
      "dependsOn": ["approve"],
      "task": "Execute the plan. Incorporate any edits:\n{steps.approve.output}\n\nPlan:\n{steps.plan.output}",
      "final": true
    }
  ]
}
```

## Example: Approve Before Destructive Changes

```jsonc
{
  "phases": [
    {
      "id": "migrate",
      "type": "agent",
      "agent": "planner",
      "task": "Plan DB migration from PostgreSQL 15 to 17. List breaking changes, transformations, rollback."
    },
    {
      "id": "confirm",
      "type": "approval",
      "dependsOn": ["migrate"],
      "task": "⚠️ Irreversible changes. Review carefully.\n\n{steps.migrate.output}"
    },
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor-code",
      "dependsOn": ["confirm"],
      "task": "Execute migration with reviewer notes:\n{steps.confirm.output}",
      "final": true
    }
  ]
}
```

## Tips
- Place before expensive or irreversible work.
- In headless/detached runs, approval auto-rejects.
- Use Edit to inject mid-run guidance.
