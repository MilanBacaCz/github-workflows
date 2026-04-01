# Self-hosted GitHub Actions Runner — Hetzner VPS

Self-hosted runner jako Docker container pro Coolify na sdíleném Hetzner VPS.

## Předinstalované nástroje

| Nástroj | Verze |
|---------|-------|
| Python | 3.11 |
| Node.js | 22 |
| Flutter | 3.41.6 |
| Java (JDK) | 17 |
| Docker CLI | latest |
| Git | latest |

## Nasazení přes Coolify

### 1. Získání Runner tokenu

1. Jdi na GitHub repo → **Settings** → **Actions** → **Runners** → **New self-hosted runner**
2. Zkopíruj token z příkazu `./config.sh --token XXXXXXX`
3. Token je platný omezeně — použij ho ihned

Pro org-level runner: **Organization Settings** → **Actions** → **Runners**

### 2. Vytvoření projektu v Coolify

1. Coolify GUI → **New Project** → název `GitHub Runner`
2. **New Resource** → **Docker Compose** → Empty
3. Nastav **Build Pack**: Docker Compose
4. **Repository**: `MilanBacaCz/github-workflows` (nebo zkopíruj `runner/` obsah)
5. **Docker Compose Location**: `runner/docker-compose.yml`

### 3. Environment Variables (v Coolify GUI)

| Proměnná | Hodnota | Povinná |
|----------|---------|---------|
| `GITHUB_REPO_URL` | `https://github.com/MilanBacaCz/mediservis` | Ano |
| `GITHUB_RUNNER_TOKEN` | Token z kroku 1 | Ano |
| `RUNNER_NAME` | `hetzner-runner` | Ne (default) |
| `RUNNER_LABELS` | `self-hosted,linux,hetzner` | Ne (default) |

### 4. Deploy

Klikni **Deploy** v Coolify. Runner se zaregistruje automaticky.

### 5. Ověření

- GitHub repo → Settings → Actions → Runners → runner by měl být "Idle"
- Coolify → projekt → healthcheck by měl být "Healthy"

## Údržba

### Obnova tokenu

Runner token vyprší. Pro obnovu:

1. Získej nový token v GitHub Settings
2. V Coolify změň env `GITHUB_RUNNER_TOKEN`
3. Restartuj službu v Coolify

### Update runner verze

Změň `RUNNER_VERSION` v Dockerfile a redeploy v Coolify.

### Fallback na GitHub hosted

Pokud je runner offline, v `mediservis/.github/workflows/ci.yml` změň:

```yaml
runner: self-hosted  →  runner: ubuntu-latest
```

## Persistentní cache

Runner udržuje cache mezi runy přes Docker volumes:

| Volume | Cesta | Pro |
|--------|-------|-----|
| `runner-pip-cache` | `~/.cache/pip` | Python packages |
| `runner-npm-cache` | `~/.npm` | Node.js packages |
| `runner-pub-cache` | `~/.pub-cache` | Dart/Flutter packages |

Díky tomu `pip install`, `npm ci` a `flutter pub get` jsou výrazně rychlejší po prvním runu.
