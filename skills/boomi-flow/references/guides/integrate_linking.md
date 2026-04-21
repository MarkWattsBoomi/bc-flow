# Linking Boomi Flow to Boomi Integrate

## Overview

Flow calls Integrate processes through **Service Elements**. The connection requires:
1. An **Integration Account** on the Flow tenant (links the two platforms)
2. A **Flow Service component** in Boomi Integrate (exposes the process)
3. A **Service element** in Boomi Flow (points to the FSS endpoint)

## Step 1: Verify Integration Account

Check if the tenant already has an Integration Account configured:
```bash
bash <skill-path>/scripts/flow-integration-list.sh
```

If configured, it prints the account ID and lists available processes. If not, the user must configure it in the Flow platform GUI under Settings → Integration.

## Step 2: List Available Integrate Processes

Once an Integration Account is configured:
```bash
bash <skill-path>/scripts/flow-integration-list.sh --account-id <account-id>
```

This shows processes that have been exposed as Flow Services in Boomi Integrate.

Get process properties (input/output parameters):
```bash
bash <skill-path>/scripts/flow-integration-list.sh \
  --properties \
  --account-id <account-id> \
  --process-id <process-id>
```

## Step 3: Create or Install a Service Element

**Option A — Install from discovered process (recommended):**

Use the service install endpoint which auto-populates the service element from the process metadata:
```bash
# POST to /api/draw/1/element/service/install with the process details
```

**Option B — Create manually:**

Build a service element JSON pointing to the FSS endpoint URL. The FSS endpoint follows this pattern:
```
https://<atom-host>/ws/simple/<fss-service-name>
```

Get service types and actions from the running service:
```json
POST /api/draw/1/element/service/typesAndActions
{
  "uri": "https://your-atom.integrate.boomi.com/ws/simple/myFlowService",
  "httpAuthenticationScheme": "HttpBasicAuthenticationScheme",
  "username": "<user>",
  "password": "<token>"
}
```

Then create the service element:
```bash
bash <skill-path>/scripts/flow-element-create.sh --type service --file service-element.json
```

## Step 4: Use the Service in a Map Element

Map elements are flow-scoped. Create them via:
```
POST /api/draw/1/flow/{flowId}/{editingToken}/element/map
```

Use `messageActions` to invoke the service action. **Do not use `dataActions` or top-level `serviceElementId`/`serviceActionName`** — those fields have no effect at runtime.

```json
{
  "developerName": "Call Get Customer",
  "elementType": "message",
  "x": 200,
  "y": 100,
  "messageActions": [
    {
      "developerName": "GetCustomer",
      "serviceElementId": "<service-element-id>",
      "serviceElementDeveloperName": "<service-developer-name>",
      "uriPart": "actions/GetCustomer",
      "inputs": [
        {
          "developerName": "<input-name>",
          "contentType": "ContentString",
          "typeElementId": null,
          "order": 0,
          "valueElementToReferenceId": { "id": "<input-value-id>" }
        }
      ],
      "outputs": [
        {
          "developerName": "<output-name>",
          "contentType": "ContentObject",
          "typeElementId": "<type-element-id>",
          "order": 0,
          "valueElementToApplyId": { "id": "<output-value-id>", "typeElementPropertyId": null }
        }
      ],
      "order": 0,
      "serviceActionName": null,
      "disabled": false
    }
  ],
  "dataActions": null,
  "outcomes": [
    {
      "developerName": "Continue",
      "nextMapElementId": "<next-map-element-id>",
      "order": 0
    }
  ]
}
```

Key fields:
- `uriPart`: from the service element's action definition (e.g. `"actions/GetCustomer"`)
- `outputs[].valueElementToApplyId`: value element to **save the response into**
- `serviceActionName`: always `null` — action is identified by `uriPart`
- `dataActions`: set to `null` when using `messageActions`

> ⚠️ Remember the two-pass rule: create all map elements without outcomes first, then re-POST with outcomes once all element IDs are known.

## Boomi Integrate Side Requirements

For Integrate processes to be callable from Flow, they need:
- A **Flow Service Server (FSS)** start shape in the process
- The process deployed to a Molecule or Cloud Atom (FSS requires HTTP listener capability)
- A **Flow Service component** wrapping the process and defining input/output types

See `bc-integration` skill references for creating FSS components and processes.
