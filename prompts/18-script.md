# Script Phase

Run a shell command directly. No subagent, zero tokens. Stdout = output.

## Template

```jsonc
{
  "phases": [
    {
      "id": "build",
      "type": "script",
      "run": "pnpm run build",          // string = shell; array = execvp (no shell)
      "timeout": 120000                 // optional — ms cap (default 60000, max 300000)
    }
  ]
}
```

## Examples

### Build + Test Pipeline
```jsonc
{
  "phases": [
    { "id": "lint", "type": "script", "run": "pnpm run lint" },
    { "id": "build", "type": "script", "run": "pnpm run build", "timeout": 120000, "dependsOn": ["lint"] },
    { "id": "test", "type": "script", "run": "pnpm run test", "dependsOn": ["build"] },
    {
      "id": "report",
      "type": "agent",
      "agent": "verifier",
      "task": "Confirm all checks passed. Report any failures.\nLint:\n{steps.lint.output}\nBuild:\n{steps.build.output}\nTest:\n{steps.test.output}",
      "dependsOn": ["test"],
      "final": true
    }
  ]
}
```

### Pass Output as Input
```jsonc
{
  "phases": [
    {
      "id": "analyze",
      "type": "agent",
      "agent": "analyst",
      "task": "Analyze the codebase and output a JSON summary."
    },
    {
      "id": "score",
      "type": "script",
      "run": ["python", "scripts/score.py"],  // array form = no shell (safe with interpolation)
      "input": "{steps.analyze.output}",       // piped to stdin
      "dependsOn": ["analyze"],
      "final": true
    }
  ]
}
```

## Tips
- Prefer `script` over asking an agent to run commands — cheaper, faster, exact output.
- String `run` goes through shell; array `run` is spawned directly (no shell injection).
- String `run` with interpolation is **rejected** (shell-injection guard) — use array form or `input` for dynamic values.
- Non-zero exit = phase failure (stderr captured).
- Excluded from cross-run cache (may have side effects).
