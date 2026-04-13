# Klang Fork of Open Creator Rails

This is Klang's fork of [ChainSafe/open-creator-rails](https://github.com/ChainSafe/open-creator-rails).

## Git Remotes

| Remote | URL | Purpose |
|---|---|---|
| `upstream` | `https://github.com/ChainSafe/open-creator-rails.git` | ChainSafe's source repo |
| `klanggames` | `https://github.com/klanggames/open-creator-rails.git` | Klang's org fork |
| `origin` | your personal fork | For PRs to klanggames |

## What diverges from upstream

The only intentional divergence is **deployment config files** — these contain Seed-specific contract addresses and token addresses:

- `packages/config/src/deployments/registries_11155111.json` (Sepolia)
- `packages/config/src/deployments/registries_84532.json` (Base Sepolia)
- `packages/config/src/deployments/token_addresses.json`

Everything else should match upstream.

## Railway files (ignore)

ChainSafe deploys on Railway. Seed deploys to **GKE on GCP** (`seed.ci` project), managed via Terraform in the `iac-gcloud` repo. The following files are ChainSafe's infra — don't use, modify, or delete them:

| File | What it is |
|---|---|
| `railway.json` | Railway build config |
| `.github/workflows/deploy-indexer.yml` | Railway blue-green deploy pipeline |
| `.github/workflows/deploy-monitoring.yml` | Railway monitoring deploy |
| `apps/indexer/RAILWAY.md` | Railway setup docs |
| `apps/indexer/monitoring/prometheus/prometheus.railway.yml` | Railway Prometheus config |

`apps/indexer/scripts/start.sh` is mostly generic (Ponder API/worker entrypoint) but references `RAILWAY_DEPLOYMENT_ID` as a fallback. Reusable with minor changes when we set up our own deploy.

## Rules

1. **Don't modify upstream TypeScript files** unless absolutely necessary. ChainSafe actively changes `apps/indexer/`, `apps/contracts/`, and `packages/config/src/index.ts`. Modifying these creates merge conflicts.
2. **Deployment JSON conflicts are expected** when pulling upstream. Always resolve by keeping Seed's values.
3. **Don't delete or modify Railway files** — they'll cause merge conflicts when syncing upstream. Just ignore them.
4. **Seed-specific features** should live in clearly separated files/directories (not mixed into upstream files).

## Pulling upstream changes

```bash
git fetch upstream
git merge upstream/main
# Resolve any deployment JSON conflicts by keeping Seed's values
```
