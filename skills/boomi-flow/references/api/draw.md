# Draw API Reference

Base path: `/api/draw/`

All endpoints require `x-boomi-flow-api-key` and `manywhotenant` headers.

## Flows

| Method | Path | Description |
|---|---|---|
| POST | `/draw/1/flow` | Create or update a flow |
| GET | `/draw/1/flow` | List flows (paginated) |
| GET | `/draw/1/flow/{id}` | Get flow by ID |
| DELETE | `/draw/1/flow/{id}` | Delete a flow |
| GET | `/draw/1/flow/active` | List active (published) flows |
| GET | `/draw/1/flow/active/{id}` | Get active flow by ID |
| GET | `/draw/1/flow/active/name/{name}` | Get active flow by name |
| GET | `/draw/1/flow/active/environment/{environmentId}` | List flows for environment |

**Flow object key fields:**
```json
{
  "id": "guid",
  "name": "string",
  "description": "string",
  "startMapElementId": "guid",
  "allowJumping": false,
  "enableHistoricalNavigation": false,
  "authorization": { ... }
}
```

## Flow Snapshots (v2)

| Method | Path | Description |
|---|---|---|
| POST | `/draw/2/flow/snapshot` | Create snapshot |
| GET | `/draw/2/flow/snapshot` | List snapshots (filter by flow query param) |
| GET | `/draw/2/flow/snapshot/{id}` | Get snapshot |
| POST | `/draw/2/flow/snapshot/{id}/activate` | Activate snapshot |
| POST | `/draw/2/flow/snapshot/deactivate` | Deactivate snapshots |
| POST | `/draw/2/flow/revert/{flow}/{version}` | Revert flow to snapshot |
| GET | `/draw/2/flow/{id}/releases` | Get releases for a flow |
| GET | `/draw/2/flow/{id}/snapshot/{versionId}/diff` | Diff two snapshots |

## HTTP Methods

The Boomi Flow Draw API is **POST-only** for all mutations. There is no PUT method.

---

## Elements (non-map types)

| Method | Path | Description |
|---|---|---|
| POST | `/draw/1/element/{type}` | Create or update element |
| GET | `/draw/1/element/{type}` | List elements (paginated) |
| GET | `/draw/1/element/{type}/{id}` | Get element |
| DELETE | `/draw/1/element/{type}/{id}` | Delete element |

**Element types (global):** `service`, `page`, `type`, `value`, `navigation`, `macro`, `theme`, `tag`, `group`, `identityprovider`, `customPageComponent`

> ⚠️ `map` is **not** a valid type for these endpoints. Map elements are flow-scoped — see below.

---

## Map Elements (flow-scoped)

Map elements use a different, flow-scoped endpoint that includes the flow ID and current editing token:

| Method | Path | Description |
|---|---|---|
| POST | `/draw/1/flow/{flowId}/{editingToken}/element/map` | Create or update a map element |
| GET | `/draw/1/flow/{flowId}/{editingToken}/element/map/{id}` | Get a map element |
| DELETE | `/draw/1/flow/{flowId}/{editingToken}/element/map/{id}` | Delete a map element |

**Key rules:**
- A fresh `editingToken` must be obtained (GET the flow) before each POST
- `elementType` uses **lowercase** values: `start`, `message`, `input`, `step`, `operator`, `modal`
- Create all elements without outcomes first; then re-POST each with outcomes once all IDs are known
- Never reference an element ID in an outcome before that element has been created

**Minimal map element body:**
```json
{ "developerName": "My Step", "elementType": "input", "x": 200, "y": 250 }
```

## Service Element Operations

| Method | Path | Description |
|---|---|---|
| POST | `/draw/1/element/service/install` | Install service (auto-creates from metadata) |
| POST | `/draw/1/element/service/typesAndActions` | Discover types and actions from service URI |
| POST | `/draw/1/element/service/configurationValues` | Get required config values |
| GET | `/draw/1/element/service/{id}/authentication` | Get auth attributes |
| POST | `/draw/1/element/service/users` | Get users/groups from service |
| GET | `/draw/2/element/service` | List services (v2, more detail) |

## Type Element Operations (v2)

| Method | Path | Description |
|---|---|---|
| GET | `/draw/2/element/type/integration/{accountId}/profile` | List integration profiles |
| GET | `/draw/2/element/type/integration/{accountId}/profile/{profileId}` | Get profile |
| GET | `/draw/2/element/type/{id}/mapping/{targetId}/auto` | Auto-map between types |

## Value Element Operations (v2)

| Method | Path | Description |
|---|---|---|
| GET | `/draw/2/element/value` | List values (v2, more detail) |
| GET | `/draw/1/element/value/{id}/references` | List where a value is referenced |

## Flow Graph

| Method | Path | Description |
|---|---|---|
| GET | `/draw/2/graph/flow/{id}` | Get flow graph (positions and connections) |
| POST | `/draw/1/graph/flow` | Update flow graph layout |

> ⚠️ **The graph API is layout-only.** It only persists: `developerName`, `developerSummary`, `x`, `y`, `height`, `width`. It cannot create map elements or wire outcomes. Use the flow-scoped map element endpoint for all logic changes.

> ⚠️ **The GET graph endpoint does NOT return element width/height.** Use these known canvas defaults when computing even-gap layouts:
>
> | elementType | width (px) |
> |---|---|
> | start | 60 |
> | operator | 120 |
> | message | 160 |
> | input | 160 |
> | step | 160 |
> | decision | 160 |
>
> Even-gap formula: `x[n+1] = x[n] + width[n] + gap` (gap = 40px recommended). All elements at the same y.

## Integration Discovery

| Method | Path | Description |
|---|---|---|
| GET | `/draw/1/integration/process` | List Integrate processes |
| GET | `/draw/1/integration/process/{accountId}/{id}` | Get specific process |
| POST | `/draw/1/integration/process/name` | Find process by name |
| GET | `/draw/1/integration/{accountId}/processproperties` | List process properties |
| GET | `/draw/1/integration/{accountId}/processproperties/{id}` | Get process properties |
| POST | `/draw/1/integration/{accountId}/processproperties/name` | Find properties by name |

## Dependencies

| Method | Path | Description |
|---|---|---|
| GET | `/draw/1/dependents/{id}` | What references this element (dependents) |
| GET | `/draw/1/dependencies/{id}` | What this element references (dependencies) |

## Assets

| Method | Path | Description |
|---|---|---|
| GET | `/draw/1/assets` | List assets |
| DELETE | `/draw/1/assets` | Delete asset |
| PUT | `/draw/1/assets` | Move asset |
| POST | `/draw/1/assets` | Create folder |
| POST | `/draw/1/assets/upload` | Generate upload URL |
| GET | `/draw/1/assets/info` | Get asset info |

## Pagination

All list endpoints support:
- `page` (default: 1)
- `pageSize` (default: 25, max: 100)
- `filter` (substring match on name)
- `orderBy` / `orderDirection`
