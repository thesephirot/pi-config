# Loop Phase

Repeat until condition met, output converges, or max iterations reached.

## Interpolation

| Placeholder | Meaning |
|-------------|---------|
| `{loop.iteration}` | 1-based current iteration |
| `{loop.lastOutput}` | Previous iteration's output |
| `{loop.maxIterations}` | The iteration cap |
| `{reflexion}` | Failure feedback (when `reflexion: true`) |

## Template

```jsonc
{
  "phases": [
    {
      "id": "refine",
      "type": "loop",
      "agent": "executor",
      "maxIterations": 5,              // required — hard cap
      "until": "{steps.refine.json.done} == true",
      "convergence": true,              // stop if output stops changing
      "reflexion": true,                // feed failure feedback to next iter
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["done", "result"]
      },
      "task": "Improve. When satisfied: {\"done\":true,\"result\":\"...\"}. Otherwise {\"done\":false,\"result\":\"...\"}.\n\nIteration {loop.iteration} of {loop.maxIterations}.\nPrevious:\n{loop.lastOutput}\n\n{reflexion}",
      "final": true
    }
  ]
}
```

## Example: Self-Correction

```jsonc
{
  "phases": [
    {
      "id": "write-code",
      "type": "loop",
      "agent": "executor-code",
      "maxIterations": 4,
      "reflexion": true,
      "until": "{steps.write-code.json.done} == true",
      "output": "json",
      "expect": { "type": "object", "required": ["done", "code", "issues"] },
      "task": "Write a CSV parser with proper escaping.\nOutput {\"done\":bool, \"code\":\"...\", \"issues\":[\"remaining\"]}.\nWhen all issues resolved, set done to true.\n\n{reflexion}",
      "final": true
    }
  ]
}
```

## Tips
- `maxIterations` is required — runtime always terminates.
- `reflexion: true` = each iteration gets feedback on why last failed.
- `convergence: true` stops early when output stops changing.
- Pair with `expect` so failures become structured feedback.
