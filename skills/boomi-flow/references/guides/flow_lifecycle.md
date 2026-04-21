# Flow Lifecycle Guide

## Overview

A Boomi Flow application moves through these stages from creation to live usage:

```
Create Flow → Add Elements → Snapshot → Activate Snapshot → Create Release → Deploy → Live
```

## Stage 1: Create Flow

Create the flow container first. This is just a named container — no elements yet.

```bash
bash <skill-path>/scripts/flow-create.sh --name "Customer Portal" --description "Self-service portal"
```

Save the returned flow ID — all subsequent elements reference it.

## Stage 2: Build Elements

Elements must be created in dependency order. See `FLOW_THINKING.md` for the correct order.

Create elements using:
```bash
bash <skill-path>/scripts/flow-element-create.sh --type <type> --file <element.json>
```

Common workflow:
1. Create Type elements (data models)
2. Create Value elements (variables)
3. Create Service elements (integrations)
4. Create Page elements (UI screens)
5. Create Map elements (flow logic, outcomes)
6. Update the Flow to reference its start map element

### Update Flow to Add Start Element

After creating map elements, update the flow to set the starting map element:
```json
{
  "id": "<flow-id>",
  "name": "Customer Portal",
  "startMapElementId": "<first-map-element-id>",
  "allowJumping": false
}
```
```bash
bash <skill-path>/scripts/flow-create.sh --id <flow-id> --file updated-flow.json
```

## Stage 3: Snapshot

Snapshot captures the current state of all elements as an immutable version.

```bash
bash <skill-path>/scripts/flow-snapshot-create.sh \
  --flow-id <flow-id> \
  --name "v1.0.0" \
  --comment "Initial release"
```

List existing snapshots:
```bash
bash <skill-path>/scripts/flow-snapshot-list.sh --flow-id <flow-id>
```

## Stage 4: Activate Snapshot

Activating makes the snapshot the "current" version. Users running the flow see this version.

```bash
bash <skill-path>/scripts/flow-snapshot-activate.sh \
  --flow-id <flow-id> \
  --snapshot-id <snapshot-id>
```

## Stage 5: Deploy to Environment

Deploying makes the flow accessible in a target environment (Test, Production, etc.).

First list available environments:
```bash
bash <skill-path>/scripts/flow-deploy.sh --list-environments
```

Get a release ID (the activate step often creates one — check `flow-release-list.sh`):
```bash
bash <skill-path>/scripts/flow-release-list.sh --flow-id <flow-id>
```

Deploy:
```bash
bash <skill-path>/scripts/flow-deploy.sh --release-id <release-id> --env-id <env-id>
```

## Rollback

If a deployment causes issues, roll back to the previous release:
```bash
bash <skill-path>/scripts/flow-rollback.sh --release-id <release-id>
```

## Monitoring Live Flows

Check running states:
```bash
bash <skill-path>/scripts/flow-state-list.sh --flow-id <flow-id>
```

View dashboard metrics:
```bash
bash <skill-path>/scripts/flow-dashboard.sh --flow-id <flow-id>
```

Check error states:
```bash
bash <skill-path>/scripts/flow-dashboard.sh --errors
```
