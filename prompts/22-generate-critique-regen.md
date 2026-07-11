# Archetype: Generate → Critique → Regenerate

Self-healing rework loop. Generate output, critique it, regenerate if blocked — up to N rounds.

## Template

```jsonc
{
  "name": "self-healing",
  "phases": [
    {
      "id": "generate",
      "type": "agent",
      "agent": "executor",
      "task": "YOUR_GENERATION_TASK"
    },
    {
      "id": "critique",
      "type": "gate",
      "agent": "critic",
      "dependsOn": ["generate"],
      "onBlock": "retry",
      "retry": { "max": 3 },
      "task": "Critique the output. Find gaps, contradictions, and missing requirements.\n\n{steps.generate.output}\n\nVERDICT: PASS or BLOCK"
    },
    {
      "id": "report",
      "type": "agent",
      "agent": "doc-writer",
      "dependsOn": ["critique"],
      "task": "Write a final summary of the approved output:\n\n{steps.generate.output}",
      "final": true
    }
  ]
}
```

## Example: Code Implementation with Adversarial Review

```jsonc
{
  "name": "code-with-review",
  "phases": [
    {
      "id": "implement",
      "type": "agent",
      "agent": "executor-code",
      "task": "Implement a rate-limiting middleware for Express. Requirements:\n- Token bucket algorithm\n- Configurable rate and burst\n- Redis-backed for distributed deployments\n- Graceful fallback to in-memory"
    },
    {
      "id": "critique",
      "type": "gate",
      "agent": "critic",
      "dependsOn": ["implement"],
      "onBlock": "retry",
      "retry": { "max": 3 },
      "task": "Adversarially review the implementation. Check for:\n- Correctness of token bucket algorithm\n- Race conditions and thread safety\n- Error handling and edge cases\n- Performance under load\n- Security (bypass vectors)\n\n{steps.implement.output}\n\nVERDICT: PASS or BLOCK"
    },
    {
      "id": "security-review",
      "type": "gate",
      "agent": "security-reviewer",
      "dependsOn": ["critique"],
      "task": "Final security review of the implementation.\n\n{steps.implement.output}\n\nVERDICT: PASS or BLOCK"
    },
    {
      "id": "report",
      "type": "agent",
      "agent": "doc-writer",
      "dependsOn": ["security-review"],
      "task": "Write documentation for the rate-limiting middleware.\n\n{steps.implement.output}",
      "final": true
    }
  ]
}
```

## How onBlock: "retry" Works

1. Gate agent reviews output → returns BLOCK with reasons.
2. Runtime re-runs upstream `dependsOn` phases (the generator).
3. Generator re-runs, incorporating gate's feedback.
4. Repeat up to `retry.max` rounds, or until PASS / budget / abort.

## Tips
- `onBlock: "retry"` + `retry.max` = self-healing loop.
- Default is `onBlock: "halt"` (flow stops on BLOCK).
- Use `critic` for adversarial review, `reviewer` for quality review.
- Pair with `budget` to cap total cost across retries.
