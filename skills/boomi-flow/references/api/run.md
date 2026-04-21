# Run API Reference

Base path: `/api/run/`

The Run API handles flow execution at runtime — initializing flows, navigating states, and managing user interactions.

## Flow Initialization

| Method | Path | Description |
|---|---|---|
| POST | `/run/1/state` | Initialize a flow (create a new state) |
| POST | `/run/2` | Initialize flow (v2) |
| POST | `/run/1/state/simple` | Initialize flow (simplified) |
| GET | `/run/1/flow/{id}` | Load flow by ID (for display) |
| GET | `/run/1/flow/name/{name}` | Load flow by name |
| GET | `/run/1/flow` | List available flows |
| GET | `/run/1/flow/environment/{environmentId}` | List active flows for environment |

**Initialize flow request:**
```json
{
  "flow": {
    "id": "flow-guid",
    "versionId": null
  },
  "mode": null,
  "reportingMode": null,
  "annotations": null
}
```

**Initialize flow response includes:**
```json
{
  "stateId": "state-guid",
  "stateToken": "token",
  "currentMapElementId": "map-element-guid",
  "pageResponse": { ... }
}
```

## State Invocation (Navigation)

| Method | Path | Description |
|---|---|---|
| POST | `/run/1/state/{id}` | Invoke flow state (select outcome, navigate) |
| POST | `/run/2/state/{stateId}` | Invoke state (v2) |
| GET | `/run/1/state/{id}/join` | Join an existing state |
| GET | `/run/2/state/{stateId}` | Get state details |
| GET | `/run/1/state/{id}/changes` | Poll for state changes |
| POST | `/run/1/navigation` | Get navigation for current state |
| POST | `/run/1/flow/out` | Flow out to another flow |

**Invoke state request (select an outcome):**
```json
{
  "stateToken": "token",
  "mapElementInvokeRequest": {
    "selectedOutcomeDeveloperName": "Submit"
  }
}
```

## State Values

| Method | Path | Description |
|---|---|---|
| GET | `/run/1/state/{id}/value` | Get all state values |
| GET | `/run/1/state/{id}/value/{name}` | Get state value by name |
| GET | `/run/1/state/{id}/values` | Get flow state values |
| POST | `/run/1/state/{id}/values` | Set flow state values |
| GET | `/run/1/state/{id}/history` | Get state navigation history |

## State Events & Listeners

| Method | Path | Description |
|---|---|---|
| POST | `/run/1/state/{id}/event` | Post a flow event |
| POST | `/run/1/state/{id}/listener` | Add a state listener |
| DELETE | `/run/1/state/{id}/listener` | Remove a state listener |
| POST | `/run/1/state/{id}/service` | Receive response from an async service |

## Authentication

| Method | Path | Description |
|---|---|---|
| POST | `/run/1/authentication` | Authenticate a user |
| GET | `/run/1/authentication/context` | Get authentication context |
| GET | `/run/1/authentication/oauth1` | OAuth 1.0a callback |
| GET | `/run/1/authentication/oauth2` | OAuth 2.0 callback |
| GET | `/run/2/oauth2` | OAuth 2.0 callback (v2) |
| POST | `/run/1/authentication/saml` | SAML assertion |
| POST | `/run/2/saml` | SAML v2 |
| POST | `/run/2/saml/initialize` | Initialize SAML flow |
| GET | `/run/1/oidc` | OIDC callback |
| GET | `/run/1/authorization` | Authorization check |

## Data & Files

| Method | Path | Description |
|---|---|---|
| POST | `/run/1/data` | Load data from service |
| POST | `/run/2/data` | Load data from service (v2) |
| POST | `/run/1/files/load` | Load files from service |
| POST | `/run/1/files/upload` | Upload file to service |
| POST | `/run/1/files/delete` | Delete file from service |
| GET | `/run/1/state/{id}/document/{fileId}/{filename}` | Download document from state |

## Logging

| Method | Path | Description |
|---|---|---|
| GET | `/run/1/log/{id}` | Get execution log |
