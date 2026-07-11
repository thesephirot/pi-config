# Tournament Phase

N competing variants in parallel, then a judge picks the best or merges them.

## Template — Best-of-N

```jsonc
{
  "phases": [
    {
      "id": "contest",
      "type": "tournament",
      "agent": "executor",
      "variants": 3,                    // 3 competing attempts
      "mode": "best",                   // judge picks winner
      "judge": "Pick the clearest, most accurate result. Return JSON {\"winner\": <n>, \"reason\": \"...\"}.",
      "judgeAgent": "reviewer",         // optional — stronger model for judging
      "task": "Write a headline for the article:\n\n{steps.draft.output}",
      "dependsOn": ["draft"],
      "final": true
    }
  ]
}
```

## Template — Aggregate Mode

```jsonc
{
  "phases": [
    {
      "id": "synthesize",
      "type": "tournament",
      "agent": "analyst",
      "variants": 4,
      "mode": "aggregate",
      "judge": "Merge these 4 perspectives into one comprehensive answer. Preserve unique insights from each.",
      "task": "Analyze the impact of microservices architecture from your perspective.",
      "final": true
    }
  ]
}
```

## Example: Design Options

```jsonc
{
  "phases": [
    {
      "id": "draft",
      "type": "agent",
      "agent": "scout",
      "task": "Summarize the current state of the auth module."
    },
    {
      "id": "designs",
      "type": "tournament",
      "agent": "planner",
      "variants": 3,
      "mode": "best",
      "judgeAgent": "plan-arbiter",
      "judge": "Evaluate each design on: security, simplicity, performance, and maintainability. Pick the best. Return {\"winner\":<n>,\"reason\":\"...\"}.",
      "task": "Propose a redesign of the auth module. Consider OAuth2, session tokens, and JWT approaches.",
      "dependsOn": ["draft"],
      "final": true
    }
  ]
}
```

## Tips
- `variants` = number of competing attempts (default 3, max 20).
- `mode: "best"` = judge picks one winner; `mode: "aggregate"` = judge merges all.
- Use a stronger agent for `judgeAgent` (e.g., `plan-arbiter`, `reviewer`).
- Prefer JSON winner format: `{"winner": <n>}` over text markers.
