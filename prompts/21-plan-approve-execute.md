# Archetype: Plan → Approve → Execute

Plan first, pause for human review, then execute only if approved.

## Template

```jsonc
{
  "name": "plan-approve-execute",
  "phases": [
    // 1. PLAN — create detailed implementation plan
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Create a detailed implementation plan for: YOUR_TASK\n\nInclude: affected files, ordered steps, risk analysis, acceptance criteria, and rollback strategy.",
      "final": false
    },
    // 2. APPROVE — human review
    {
      "id": "approve",
      "type": "approval",
      "dependsOn": ["plan"],
      "task": "Review this plan before execution. Approve, reject, or edit to add guidance:\n\n{steps.plan.output}"
    },
    // 3. EXECUTE — run the approved plan
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor-code",
      "dependsOn": ["approve"],
      "task": "Execute the approved plan.\n\nIf there are edits from approval, incorporate them:\n{steps.approve.output}\n\nOriginal plan:\n{steps.plan.output}",
      "final": true
    }
  ]
}
```

## With Pre-Execution Gate

```jsonc
{
  "name": "plan-approve-gate-execute",
  "phases": [
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Create implementation plan for: YOUR_TASK"
    },
    {
      "id": "human-check",
      "type": "approval",
      "dependsOn": ["plan"],
      "task": "Review this plan:\n\n{steps.plan.output}"
    },
    {
      "id": "arbiter",
      "type": "gate",
      "agent": "plan-arbiter",
      "dependsOn": ["plan", "human-check"],
      "task": "Check the plan for bad assumptions, scope creep, missing risks. Consider human feedback:\n{steps.human-check.output}\n\nPlan:\n{steps.plan.output}\n\nVERDICT: PASS or BLOCK"
    },
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor-code",
      "dependsOn": ["arbiter"],
      "task": "Execute the plan.\n\n{steps.plan.output}",
      "final": true
    }
  ]
}
```

## Tips
- Use before expensive or irreversible work.
- `steps.approve.output` = `(approve)` if approved, or your edit notes.
- Add a `gate` phase after approval for automated plan validation.
- In headless/detached runs, approval auto-rejects.
