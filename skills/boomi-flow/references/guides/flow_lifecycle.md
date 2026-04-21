# Flow Lifecycle Guide

## Overview

A Boomi Flow application moves through these stages from creation to live usage:

```
Create Flow → Add Elements → Live (immediately)
```

**There is no separate snapshot or activate step required to make a flow runnable.** Every POST update to a flow makes it live immediately. The flow is versioned automatically on each change — the current versionId is always the live version.

**Snapshots are history only** — they provide access to the flow's past states but are not a deployment mechanism. Do not attempt to create or activate a snapshot as part of a build workflow.

To run a flow after building: GET the flow to retrieve the current `versionId`, then construct the run URL:
```
{FLOW_BASE_URL}/{FLOW_TENANT_ID}/play/default/?flow-id={flowId}&flow-version-id={versionId}
```

> ⚠️ The `versionId` changes on every edit. Always GET the flow immediately before constructing a run URL.

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
5. Create Map elements — **two-pass process** (see Map Elements below)
6. The flow's `startMapElementId` is auto-set to a START element on creation

### Map Elements — Two-Pass Creation

Map elements are **flow-scoped** and use a different endpoint than other elements:
```
POST /api/draw/1/flow/{flowId}/{editingToken}/element/map
```
GET and DELETE use the same path with the element ID appended.

**Important rules:**
- The Flow API is **POST-only** — there is no PUT method
- `elementType` uses **lowercase** values: `start`, `message`, `input`, `step`, `operator`, `modal`
- Create all map elements **without outcomes** first, then re-POST each with outcomes once all IDs are known
- Never reference a map element ID in an outcome before that element has been created

**Pass 1 — Create each element (no outcomes):**
```bash
# Fresh editingToken required for each POST
curl -X POST "$FLOW_BASE_URL/api/draw/1/flow/$FLOW_ID/$TOKEN/element/map" \
  -d '{"developerName":"My Step","elementType":"input","x":200,"y":250}'
# Capture the returned "id" field
```

**Pass 2 — Re-POST each element with outcomes filled in:**
```bash
curl -X POST "$FLOW_BASE_URL/api/draw/1/flow/$FLOW_ID/$TOKEN/element/map" \
  -d '{"id":"<element-id>","developerName":"My Step","elementType":"input","x":200,"y":250,
       "outcomes":[{"developerName":"Next","nextMapElementId":"<other-id>","order":0}]}'
```

The auto-created START element (`startMapElementId` from the flow response) should also be updated in Pass 2 to add an outcome pointing to the first real step.

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

## Stage 3: Run the Flow

After building elements and wiring outcomes, the flow is immediately live. Construct the run URL:

```bash
source .env
FLOW_JSON=$(curl -s -H "x-boomi-flow-api-key: $FLOW_API_KEY" -H "manywhotenant: $FLOW_TENANT_ID" \
  "$FLOW_BASE_URL/api/draw/1/flow/$FLOW_ID")
VERSION_ID=$(echo "$FLOW_JSON" | grep -o '"versionId":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "$FLOW_BASE_URL/$FLOW_TENANT_ID/play/default/?flow-id=$FLOW_ID&flow-version-id=$VERSION_ID"
```

---

## Snapshots (History Only)

Snapshots record the flow's history — they are **not** required to make a flow runnable.

```bash
# List history
bash <skill-path>/scripts/flow-snapshot-list.sh --flow-id <flow-id>
```

---

## Stage 4 (Optional): Deploy to Environment

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
