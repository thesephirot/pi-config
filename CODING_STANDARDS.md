# Coding Standards & Guidelines

This document defines the coding standards for this repository. All contributors (including AI workers) must adhere to these guidelines to ensure consistency, maintainability, and reliability.

## 1. General Principles
- **Readability over Cleverness**: Write code that is easy to understand. Avoid overly complex one-liners.
- **Simplicity**: Prefer simple, explicit logic over "magic" or highly abstract patterns unless necessary.
- **Consistency**: Follow the existing patterns in the codebase. If you improve a pattern, update this document.
- **Dry (Don't Repeat Yourself)**: Extract common logic into helpers, but avoid over-engineering abstractions.

## 2. TypeScript & JavaScript Standards

### 2.1 Type Safety
- **No `any`**: Avoid `any` at all costs. Use `unknown` if the type is truly unknown, or define a proper interface/type.
- **Strict Typing**: Enable and adhere to `strict` mode in `tsconfig.json`.
- **Explicit Return Types**: Always define return types for public functions and complex logic to improve readability and prevent accidental type changes.

### 2.2 Syntax & Constraints (Erasable Syntax)
To support Node.js strip-only mode, use only **erasable TypeScript syntax**. The following are **forbidden**:
- `enum` (Use union types or objects with `as const`).
- `namespace` or `module`.
- Parameter properties in constructors (e.g., `constructor(public name: string) {}`). Use explicit fields and assignments.
- `import =` or `export =`.

### 2.3 Imports & Modules
- **Top-level Imports Only**: No inline/dynamic imports (`await import()`) unless strictly required by the runtime environment.
- **Absolute/Aliased Paths**: Use path aliases (e.g., `@/src/...`) instead of deep relative paths (`../../../`).

### 2.4 Naming Conventions
- **Variables & Functions**: `camelCase`
- **Classes & Interfaces**: `PascalCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Files**: `kebab-case` (e.g., `user-service.ts`)
- **Private Members**: Prefix with `_` or use the `private` keyword.

## 3. Architecture & Design

### 3.1 Function Design
- **Single Responsibility**: A function should do one thing and do it well.
- **Pure Functions**: Prefer pure functions (no side effects) for business logic to make testing easier.
- **Inline Helpers**: Small helper functions used in only one place should be inlined or kept private within the module.

### 3.2 Error Handling
- **Explicit Errors**: Use custom error classes for domain-specific errors.
- **Avoid Silent Failures**: Never use empty `catch` blocks. Always log the error or re-throw it.
- **Result Pattern**: For operations that can fail frequently, consider returning a Result object `{ success: boolean, data?: T, error?: Error }` instead of throwing exceptions.

## 4. Testing Standards

### 4.1 Requirements
- **Unit Tests**: Every new feature or bug fix must include unit tests.
- **Coverage**: Aim for high coverage of business logic; avoid testing third-party libraries.
- **Test Isolation**: Tests must be independent and not rely on shared state.

### 4.2 Tooling
- Use the project's designated test runner (e.g., Vitest, Jest).
- Follow the `Arrange-Act-Assert` pattern.

## 5. Documentation

### 5.1 Code Documentation
- **JSDoc**: Use JSDoc for public APIs, complex algorithms, and non-obvious logic.
- **Self-Documenting Code**: Prioritize clear naming over comments. Comments should explain *why*, not *what*.

### 5.2 Project Documentation
- Keep the `README.md` updated with setup and usage instructions.
- Document architectural decisions in an `ADR` (Architecture Decision Record) folder if applicable.

## 6. Git & Workflow

### 6.1 Commit Messages
Follow the strict format: `{type}[(scope)]: <message>`
- **Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.
- **Scopes**: `ai`, `tui`, `agent`, `coding-agent`, etc.
- **Example**: `feat(ai): implement streaming response handler`

### 6.2 Pull Requests
- **Small PRs**: Keep PRs focused on a single task.
- **Verification**: Ensure all tests pass and linting is clean before submitting.
- **Descriptions**: Provide a clear description of the change and how to verify it.
