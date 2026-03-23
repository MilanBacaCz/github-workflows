# Centralized GitHub Actions Workflows

Reusable CI/CD workflows for all projects. Call from any repo via `uses:`.

## Available Workflows

| Workflow | Tech Stack | Jobs |
|----------|-----------|------|
| `ci-python.yml` | Python (ruff, mypy, pytest, pip-audit, bandit) | lint, typecheck, test, security |
| `ci-php.yml` | PHP (PHPStan, PHPUnit, composer audit) | lint, test, security |
| `ci-typescript.yml` | TypeScript (ESLint, tsc, vitest/jest, npm audit) | lint, typecheck, test, security |
| `ci-flutter.yml` | Flutter/Dart (dart analyze, flutter test) | analyze, test, build |
| `ci-e2e-playwright.yml` | Playwright E2E (cross-stack) | e2e |
| `pr-review.yml` | PR review (coverage comment, labeling) | coverage-comment, label-pr |

## Usage

In your project's `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
    branches: [develop]
  pull_request:
    branches: [develop]

jobs:
  backend:
    uses: MilanBacaCz/github-workflows/.github/workflows/ci-python.yml@main
    with:
      working-directory: backend
      coverage-package: src/myapp
    secrets:
      env-vars: |
        SECRET_KEY=ci-dummy-key

  pr-review:
    if: github.event_name == 'pull_request'
    needs: [backend]
    uses: MilanBacaCz/github-workflows/.github/workflows/pr-review.yml@main
    with:
      working-directory: backend
      coverage-package: src/myapp
    secrets:
      env-vars: |
        SECRET_KEY=ci-dummy-key
```

## Updating

All projects reference `@main`. Push changes here → all projects get the update on next CI run.
