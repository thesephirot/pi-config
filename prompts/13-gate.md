# Gate Phase

Quality/review step that can **halt the workflow**. Agent returns PASS or BLOCK.

## Template — JSON Contract (Preferred)

```jsonc
{
  "phases": [
    {
      "id": "work",
      "type": "agent",
      "agent": "executor",
      "task": "YOUR_WORK_TASK"
    },
    {
      "id": "review",
      "type": "gate",
      "agent": "reviewer",
      "dependsOn": ["work"],
      "output": "json",
      "expect": {
        "type": "object",
        "properties": {
          "verdict": { "enum": ["pass", "block"] },
          "reason": { "type": "string" }
        },
        "required": ["verdict", "reason"]
      },
      "task": "Review the output. Respond ONLY with JSON: {\"verdict\":\"pass\"|\"block\",\"reason\":\"...\"}\n\n{steps.work.output}",
      "final": true
    }
  ]
}
```

## Template — Free Text (VERDICT marker)

```jsonc
{
  "phases": [
    {
      "id": "review",
      "type": "gate",
      "agent": "reviewer",
      "dependsOn": ["work"],
      "task": "Review for quality issues.\n\n{steps.work.output}\n\nVERDICT: PASS or BLOCK"
    }
  ]
}
```

## With Machine Checks (eval) Before LLM

```jsonc
{
  "phases": [
    { "id": "build", "type": "script", "run": "pnpm run build" },
    { "id": "test", "type": "script", "run": "pnpm run test" },
    {
      "id": "quality",
      "type": "gate",
      "dependsOn": ["build", "test"],
      // Zero-token: auto-pass if all eval pass → no LLM call
      "eval": [
        "{steps.build.output} contains BUILD SUCCESS",
        "{steps.test.output} contains 0 failed"
      ],
      // Falls through to LLM only if machine checks fail
      "task": "Build or tests failed. Analyze and decide if fixable.\nBuild:\n{steps.build.output}\nTests:\n{steps.test.output}\n\nVERDICT: PASS or BLOCK"
    }
  ]
}
```

## Self-Healing (onBlock: "retry")

```jsonc
{
  "phases": [
    {
      "id": "implement",
      "type": "agent",
      "agent": "executor",
      "task": "Implement the feature."
    },
    {
      "id": "gate",
      "type": "gate",
      "agent": "critic",
      "dependsOn": ["implement"],
      "onBlock": "retry",
      "retry": { "max": 3 },
      "task": "Does the implementation satisfy ALL requirements? List gaps.\n\n{steps.implement.output}\n\nVERDICT: PASS or BLOCK"
    }
  ]
}
```
> On BLOCK, re-runs `implement` with feedback, up to 3 rounds.

## Tips
- **Prefer JSON contract** — verdicts can't be silently misread.
- `eval` for machine-checkable conditions saves tokens.
- `onBlock: "retry"` = self-healing loop (upstream re-runs with feedback).
