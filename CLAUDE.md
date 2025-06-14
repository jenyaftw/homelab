# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Kubernetes homelab GitOps repository using FluxCD v2 for automated deployment and management of home infrastructure. The repository follows a structured GitOps pattern where all changes are made through Git commits, and Flux automatically syncs them to the cluster.

## Key Commands

### Flux Reconciliation
To manually trigger Flux to sync changes immediately (instead of waiting for the interval):
```bash
./reconcile.sh
# Or directly:
flux reconcile -n flux-system kustomization flux-system --with-source
```

### Working with Secrets
Secrets are encrypted using SOPS with age encryption. The age public key is: `age1h440ezlz0n2wf57mvdzfes8hglf7p543ryggjwgywlwlrwlmhczs4qtdzz`

To decrypt a secret file:
```bash
sops -d <secret-file.yaml>
```

To encrypt a new secret file:
```bash
sops -e <secret-file.yaml> > <secret-file.yaml>
```

### Validating Kubernetes Manifests
Before committing changes, validate YAML syntax:
```bash
# For a specific file
kubectl --dry-run=client apply -f <file.yaml>

# For kustomization builds
kubectl kustomize <directory>
```

## Architecture & Structure

### Directory Layout
- **`/clusters/serenity/`**: Cluster entry point with Flux system components and top-level kustomizations
- **`/apps/`**: Application deployments with base configurations and cluster-specific overlays
- **`/infra/`**: Infrastructure components (ingress, cert-manager, databases, etc.)

### Deployment Flow
1. Flux watches the `main` branch of this repository
2. Changes to `/clusters/serenity/` are automatically applied
3. Infrastructure components (`infra.yaml`) are deployed before applications (`apps.yaml`)
4. Each app/infra component uses Kustomization with dependency management

### Key Patterns

#### Adding a New Application
1. Create base configuration in `/apps/base/<app-name>/`
2. Add kustomization.yaml with namespace and resources
3. Add cluster-specific overlay in `/apps/serenity/<app-name>/`
4. Update `/apps/serenity/kustomization.yaml` to include the new app

#### HelmRelease Pattern
Most applications use HelmRelease with this structure:
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: app-name
spec:
  interval: 15m
  chart:
    spec:
      chart: chart-name
      sourceRef:
        kind: HelmRepository
        name: repo-name
        namespace: flux-system
  values:
    # Application-specific values
```

#### Variable Substitution
The cluster uses ConfigMaps for variable substitution in deployments:
- Cluster-wide variables in `/clusters/serenity/flux-system/config-map.yaml`
- Variables are substituted using `${VARIABLE_NAME}` syntax
- Common variables: `${CLUSTER_DOMAIN}`, `${CLUSTER_NAME}`, `${TZ}`, `${CLUSTER_LD}`

### Service Categories

**Media Stack**: Jellyfin, Radarr, Sonarr, Prowlarr, SABnzbd - all under `/apps/base/media/`
**Home Automation**: Home Assistant with Zigbee2MQTT
**Infrastructure**: PostgreSQL, Redis, RabbitMQ, ingress-nginx, cert-manager, external-dns
**Development**: Jenkins, GitHub Actions runners (ARC)