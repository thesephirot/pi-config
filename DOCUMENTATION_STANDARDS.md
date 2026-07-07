# Documentation Standards

This document defines the documentation standards for this repository. All contributors (including AI agents) must adhere to these guidelines to ensure consistency and maintainability.

## 1. General Principles

- **Accuracy**: Documentation must match the actual configuration. Verify claims against the source files.
- **Completeness**: Cover all configurable settings, not just the defaults.
- **Consistency**: Use the same terminology, formatting, and structure across all docs.
- **Cross-References**: Link related documents (e.g., AGENTS.md → CONFIG.md) instead of duplicating content.

## 2. Markdown Standards

### 2.1 Headings

- Use ATX-style headings (`#`, `##`, `###`)
- Do NOT use emojis in headings
- Maintain a logical hierarchy (H1 → H2 → H3)
- Each document has exactly one H1 (the title)

### 2.2 File Names

- Use `kebab-case` for documentation files (e.g., `documentation-standards.md`)
- Agent definition files use `PascalCase` (e.g., `Orchestrator.md`, `Coder.md`)
- Configuration files use `kebab-case` (e.g., `config.yaml`)

### 2.3 Code Blocks

- Always specify the language for fenced code blocks (e.g., ````yaml`, ````json`, ````bash`)
- Use absolute file paths in all code references
- Keep examples minimal and self-contained

### 2.4 Links

- Use relative paths for internal links (e.g., `[CONFIG.md](CONFIG.md)`)
- Use full URLs for external links
- Verify all links resolve correctly before committing

## 3. Agent Definition Standards

### 3.1 Frontmatter

Every agent `.md` file must include:

- **`description`**: One-line description of the agent's role
- **`display_name`**: Human-readable name (matches the agent key used in taskflow)
- **`model`**: Model ID, with `:thinking`/`:nothinking` suffix when applicable
- **`tools`**: Comma-separated list of accessible tools
- **`max_turns`**: Maximum tool-call rounds

Optional fields:

- **`thinking`**: Thinking mode intensity (`low` | `medium` | `high`)
- **`prompt_mode`**: System prompt handling (`replace` to override default)
- **`enabled`**: Set to `false` to disable an agent

### 3.2 Body Structure

Each agent file should contain:

1. **Role**: What this agent does and when to use it
2. **Constraints**: What this agent must NOT do
3. **Tool Usage**: Which tools to use and how
4. **Output**: Expected output format and conventions

### 3.3 Constraint Consistency

- Tools declared in frontmatter must align with constraints in the body
- If constraints say "NEVER use X", remove X from the tools list
- If tools include X but constraints don't mention it, add a usage guideline

## 4. Configuration Standards

### 4.1 config.yaml

- No trailing whitespace on any line
- No double spaces (use single spaces between arguments)
- Command-line parameters consistent across models (e.g., `--temp 0.1`)
- `filters.setParamsByID` is the single source of truth for suffixed model variants
- Comment out unused models instead of deleting them

### 4.2 Documentation Sync

- Always update documentation when configuration changes
- README examples must match actual config values
- CONFIG.md must document all available frontmatter fields and settings

## 5. Git Standards

### 5.1 Commit Messages

Follow the format: `{type}[(scope)]: <message>`

- **Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- **Scopes**: `config`, `agent`, `doc`, `taskflow`
- **Example**: `docs(config): fix agent model references in README`

### 5.2 Pull Requests

- Keep changes focused on a single concern
- List all files modified and the nature of each change
- Include verification steps for the reviewer
