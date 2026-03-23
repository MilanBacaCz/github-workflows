# Centralized GitHub Actions Workflows

Reusable CI/CD workflows for all projects. Call from any repo via `uses:`.

## CI Workflows

| Workflow | Tech Stack | Jobs |
|----------|-----------|------|
| `ci-python.yml` | Python (ruff, mypy, pytest, pip-audit, bandit) | lint, typecheck, test, security |
| `ci-php.yml` | PHP (PHPStan, PHPUnit, composer audit) | lint, test, security |
| `ci-typescript.yml` | TypeScript (ESLint, tsc, vitest/jest, npm audit) | lint, typecheck, test, security |
| `ci-flutter.yml` | Flutter/Dart (dart analyze, flutter test) | analyze, test, build |
| `ci-e2e-playwright.yml` | Playwright E2E (cross-stack) | e2e |
| `pr-review.yml` | PR review (coverage comment, labeling) | coverage-comment, label-pr |

## Build & Deploy Workflows

| Workflow | Platform | Output |
|----------|---------|--------|
| `build-flutter.yml` | Android + iOS | APK/AAB, IPA |
| `build-python-desktop.yml` | macOS + Windows | .app/.dmg/.pkg, .exe/.zip |
| `release.yml` | Cross-platform | GitHub Release with artifacts |
| `deploy-google-play.yml` | Android | Upload to Google Play (any track) |
| `deploy-testflight.yml` | iOS | Upload to TestFlight |

## Usage Examples

### CI Pipeline (Python backend)

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

### Release Pipeline (Flutter + Google Play)

```yaml
name: Release
on:
  push:
    tags: ["v*"]

jobs:
  build:
    uses: MilanBacaCz/github-workflows/.github/workflows/build-flutter.yml@main
    with:
      working-directory: mobile
      android-format: appbundle
    secrets:
      keystore-base64: ${{ secrets.KEYSTORE_BASE64 }}
      keystore-password: ${{ secrets.KEYSTORE_PASSWORD }}
      key-alias: ${{ secrets.KEY_ALIAS }}
      key-password: ${{ secrets.KEY_PASSWORD }}

  release:
    needs: [build]
    uses: MilanBacaCz/github-workflows/.github/workflows/release.yml@main
    with:
      artifact-names: "android-build"

  deploy:
    needs: [release]
    uses: MilanBacaCz/github-workflows/.github/workflows/deploy-google-play.yml@main
    with:
      package-name: com.example.myapp
      track: internal
    secrets:
      google-play-service-account-json: ${{ secrets.GOOGLE_PLAY_SA_JSON }}
```

### Release Pipeline (Python Desktop — macOS)

```yaml
name: Release
on:
  push:
    tags: ["v*"]

jobs:
  build:
    uses: MilanBacaCz/github-workflows/.github/workflows/build-python-desktop.yml@main
    with:
      app-name: MyApp
      build-script: scripts/build.sh
      build-macos: true

  release:
    needs: [build]
    uses: MilanBacaCz/github-workflows/.github/workflows/release.yml@main
    with:
      artifact-names: "macos-app,macos-pkg,macos-dmg"
```

## Updating

All projects reference `@main`. Push changes here → all projects get the update on next CI run.

## Required Secrets (per project)

| Secret | Used by | Description |
|--------|---------|-------------|
| `KEYSTORE_BASE64` | build-flutter | Android signing keystore |
| `KEYSTORE_PASSWORD` | build-flutter | Keystore password |
| `KEY_ALIAS` | build-flutter | Key alias |
| `KEY_PASSWORD` | build-flutter | Key password |
| `GOOGLE_PLAY_SA_JSON` | deploy-google-play | Service account JSON |
| `APP_STORE_CONNECT_*` | deploy-testflight | API key, issuer ID |
