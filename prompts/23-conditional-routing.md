# Archetype: Conditional Routing

Triage the task, route to different branches based on decision, then merge results.

## Template

```jsonc
{
  "name": "conditional-routing",
  "phases": [
    // 1. TRIAGE — classify and decide route
    {
      "id": "triage",
      "type": "agent",
      "agent": "analyst",
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["route"],
        "properties": {
          "route": { "enum": ["deep", "quick"] }
        }
      },
      "task": "Classify this task: YOUR_TASK\nOutput ONLY {\"route\":\"deep\"} or {\"route\":\"quick\"}."
    },
    // 2. BRANCH A — deep analysis
    {
      "id": "deep",
      "type": "agent",
      "agent": "analyst",
      "dependsOn": ["triage"],
      "when": "{steps.triage.json.route} == deep",
      "task": "Perform deep analysis of:\nYOUR_TASK"
    },
    // 3. BRANCH B — quick fix
    {
      "id": "quick",
      "type": "agent",
      "agent": "executor-fast",
      "dependsOn": ["triage"],
      "when": "{steps.triage.json.route} == quick",
      "task": "Apply a quick fix for:\nYOUR_TASK"
    },
    // 4. MERGE — combine results (joins on whichever branch ran)
    {
      "id": "report",
      "type": "reduce",
      "from": ["deep", "quick"],
      "join": "any",
      "agent": "doc-writer",
      "dependsOn": ["deep", "quick"],
      "task": "Write a summary of the work done.\n\nTriage decided: {steps.triage.json.route}\n\nResult:\n{steps.deep.output}{steps.quick.output}",
      "final": true
    }
  ]
}
```

## Example: Bug Triage

```jsonc
{
  "name": "bug-triage",
  "phases": [
    {
      "id": "triage",
      "type": "agent",
      "agent": "analyst",
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["severity", "route"],
        "properties": {
          "severity": { "enum": ["critical", "normal", "trivial"] },
          "route": { "enum": ["investigate", "fix-now", "defer"] }
        }
      },
      "task": "Analyze this bug report: BUG_DESCRIPTION\nOutput {\"severity\":\"critical\"|\"normal\"|\"trivial\",\"route\":\"investigate\"|\"fix-now\"|\"defer\"}."
    },
    {
      "id": "investigate",
      "type": "agent",
      "agent": "analyst",
      "dependsOn": ["triage"],
      "when": "{steps.triage.json.route} == investigate",
      "task": "Deep investigation of critical bug:\nBUG_DESCRIPTION\n\nRoot cause analysis required."
    },
    {
      "id": "fix",
      "type": "agent",
      "agent": "executor-fast",
      "dependsOn": ["triage"],
      "when": "{steps.triage.json.route} == fix-now",
      "task": "Apply fix for bug:\nBUG_DESCRIPTION"
    },
    {
      "id": "report",
      "type": "reduce",
      "from": ["investigate", "fix"],
      "join": "any",
      "agent": "doc-writer",
      "dependsOn": ["investigate", "fix"],
      "task": "Summarize the outcome.\nSeverity: {steps.triage.json.severity}\nRoute: {steps.triage.json.route}\nResult:\n{steps.investigate.output}{steps.fix.output}",
      "final": true
    }
  ]
}
```

## Tips
- `when` guards skip the phase unless condition is truthy.
- `join: "any"` on the merge phase = runs as soon as one branch completes.
- Use `expect` with `enum` on the triage phase — prevents silent routing failures.
- Parse errors in `when` fail **open** (phase runs).
