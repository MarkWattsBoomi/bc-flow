# Boomi Flow Elements Reference Guide

## Element Types Overview

| Type | Draw API path | Purpose |
|---|---|---|
| `type` | `/draw/1/element/type` | Data model (like a class/schema) |
| `value` | `/draw/1/element/value` | Variable/storage |
| `service` | `/draw/1/element/service` | Integration connector |
| `page` | `/draw/1/element/page` | UI screen definition |
| `map` | `/draw/1/element/map` | Flow logic step |
| `navigation` | `/draw/1/element/navigation` | Navigation menu |
| `macro` | `/draw/1/element/macro` | Server-side scripted logic |
| `theme` | `/draw/1/element/theme` | Visual styling |
| `tag` | `/draw/1/element/tag` | Labels/filters |
| `group` | `/draw/1/element/group` | Canvas grouping |
| `identityprovider` | `/draw/1/element/identityprovider` | Auth config |
| `customPageComponent` | `/draw/1/element/customPageComponent` | Custom UI component |

---

## Type Element

Defines a data model. Types have properties (fields) with primitive content types.

**Content types:** `ContentString`, `ContentNumber`, `ContentBoolean`, `ContentDateTime`, `ContentList`, `ContentObject`, `ContentPassword`, `ContentContent`

**Minimum viable type element:**
```json
{
  "developerName": "Customer",
  "developerSummary": "Customer record",
  "properties": [
    {
      "developerName": "firstName",
      "contentType": "ContentString"
    },
    {
      "developerName": "lastName",
      "contentType": "ContentString"
    },
    {
      "developerName": "email",
      "contentType": "ContentString"
    }
  ]
}
```

---

## Value Element

Stores data during a flow execution. References a Type element for complex objects.

**Content types:** Same as Type properties. Use `ContentList` for arrays of typed objects.

**Minimum viable value element:**
```json
{
  "developerName": "Current Customer",
  "contentType": "ContentObject",
  "typeElementId": "<type-element-id>",
  "defaultContentValue": null,
  "isFixed": false,
  "access": "PRIVATE"
}
```

**Access levels:** `PRIVATE` (internal), `INPUT` (flow input parameter), `OUTPUT` (flow output parameter)

**Primitive value (no type reference):**
```json
{
  "developerName": "Search Term",
  "contentType": "ContentString",
  "defaultContentValue": "",
  "isFixed": false,
  "access": "INPUT"
}
```

---

## Service Element

Connects to an external system. Service elements expose **Actions** (methods) that map elements can invoke.

**Service element structure:**
```json
{
  "developerName": "CRM Service",
  "uri": "https://your-atom.integrate.boomi.com/ws/simple/flowService",
  "httpAuthenticationScheme": "HttpBasicAuthenticationScheme",
  "username": "flow-user",
  "password": "token",
  "actions": [
    {
      "developerName": "GetCustomer",
      "uriPart": "getCustomer",
      "serviceActionBindings": []
    }
  ]
}
```

For Boomi Integrate Flow Service connections, use the FSS endpoint URL as `uri`.

---

## Page Element

Defines a UI screen. Pages contain page containers which contain page components (form fields, buttons, tables, etc.).

**Component types:** `PRESENTATION`, `INPUT`, `SELECT`, `TEXTAREA`, `CHECKBOX`, `RADIO`, `HIDDEN`, `IMAGE`, `CONTENT`, `TABLE`, `PAGINATION`, `COMBOBOX`, `FILES`, `LIST`, `OUTCOMES`

**Important:** The `elementType` for a page must be `PAGE_LAYOUT` (not `PAGE`).

**Page components are a flat top-level array** — do NOT nest them inside `pageContainers`. Each component references its container via `pageContainerId` (the container's GUID) AND `pageContainerDeveloperName`. Both fields are required.

**Minimum page element:**
```json
{
  "elementType": "PAGE_LAYOUT",
  "developerName": "Customer Form",
  "label": "Enter Customer Details",
  "pageContainers": [
    {
      "id": "<container-guid-after-first-save>",
      "developerName": "Main",
      "label": "Customer Details",
      "containerType": "VERTICAL_FLOW",
      "order": 0,
      "pageContainers": []
    }
  ],
  "pageComponents": [
    {
      "developerName": "firstName",
      "label": "First Name",
      "componentType": "INPUT",
      "contentType": "ContentString",
      "isRequired": true,
      "order": 0,
      "pageContainerDeveloperName": "Main",
      "pageContainerId": "<container-guid-after-first-save>"
    }
  ]
}
```

> ⚠️ The `pageContainerId` GUID is assigned by the platform on the first save. Workflow: (1) POST the page with containers only, (2) capture container IDs from the response, (3) re-POST with `pageComponents` referencing those IDs.

### TABLE Component — Data Binding

A TABLE component has two distinct value bindings:

| Field | Purpose | Platform term |
|---|---|---|
| `valueElementDataBindingReferenceId` | **Data source** — the list value that populates the rows | Data binding |
| `valueElementValueBindingReferenceId` | **Selected row** — the value element that receives the row the user clicks | State value |

```json
{
  "developerName": "ComponentsTable",
  "componentType": "TABLE",
  "contentType": "ContentList",
  "pageContainerDeveloperName": "Main",
  "pageContainerId": "<container-guid>",
  "valueElementDataBindingReferenceId": {
    "id": "<list-value-id>",
    "typeElementPropertyId": null
  },
  "valueElementValueBindingReferenceId": {
    "id": "<selected-item-value-id>",
    "typeElementPropertyId": null
  },
  "columns": [
    {
      "developerName": "name",
      "label": "Name",
      "order": 0,
      "isDisplayValue": true,
      "componentType": "PRESENTATION",
      "typeElementPropertyId": "<type-property-guid>"
    }
  ]
}
```

---

## Map Element

The core logic unit. Each map element represents a step in the flow. Map elements have **Outcomes** (transitions to other map elements).

**Map elements are flow-scoped.** They use a different endpoint than other elements:
```
POST /api/draw/1/flow/{flowId}/{editingToken}/element/map
```
A fresh `editingToken` (GET the flow) is required before each POST.

**`elementType` values are lowercase:** `start`, `input`, `step`, `message`, `operator`, `modal`, `decision`, `database_load`, `database_save`, `database_delete`, `return`, `sub_flow`, `wait`

**Creation order — two passes:**
1. POST each element with no outcomes → capture IDs
2. Re-POST each element with its `id` and outcomes referencing the other elements' IDs

**Input map element (shows a page, waits for user):**
```json
{
  "developerName": "Show Customer Form",
  "elementType": "input",
  "pageElementId": "<page-element-id>",
  "x": 100,
  "y": 100,
  "outcomes": [
    {
      "developerName": "Submit",
      "nextMapElementId": "<next-map-element-id>",
      "order": 0
    }
  ]
}
```

**Message map element (calls a service action):**

Use `messageActions` to invoke a service. Do **not** use `dataActions` or top-level `serviceElementId`/`serviceActionName` — those have no effect at runtime.

```json
{
  "developerName": "Get Components",
  "elementType": "message",
  "x": 200,
  "y": 250,
  "messageActions": [
    {
      "developerName": "GetComponents",
      "serviceElementId": "<service-element-id>",
      "serviceElementDeveloperName": "ComponentStore",
      "uriPart": "actions/GetComponents",
      "inputs": [
        {
          "developerName": "keyword",
          "contentType": "ContentString",
          "typeElementId": null,
          "order": 0,
          "valueElementToReferenceId": null
        }
      ],
      "outputs": [
        {
          "developerName": "Components",
          "contentType": "ContentList",
          "typeElementId": "<type-element-id>",
          "order": 0,
          "valueElementToApplyId": {
            "id": "<value-element-id>",
            "typeElementPropertyId": null
          }
        }
      ],
      "order": 0,
      "serviceActionName": null,
      "disabled": false
    }
  ],
  "dataActions": null,
  "outcomes": [
    { "developerName": "Next", "nextMapElementId": "<next-id>", "order": 0 }
  ]
}
```

Key `messageActions` fields:
- `uriPart`: from the service element's action definition (e.g. `"actions/GetComponents"`)
- `outputs[].valueElementToApplyId`: the value to **save the response into**
- `serviceActionName`: always `null` — action is identified by `uriPart`
- `dataActions`: set to `null` when using `messageActions`

**Operator map element (manipulates values):**

```json
{
  "developerName": "Empty Components",
  "elementType": "operator",
  "x": 130,
  "y": 250,
  "operations": [
    {
      "valueElementToApplyId": {
        "id": "<value-element-id>",
        "typeElementPropertyId": null,
        "command": null
      },
      "valueElementToReferenceId": null,
      "operand": "EMPTY",
      "order": 0,
      "disabled": false
    }
  ],
  "outcomes": [
    { "developerName": "Next", "nextMapElementId": "<next-id>", "order": 0 }
  ]
}
```

Operator `operand` values: `EMPTY` (clear the value), `VALUE` (set a literal), `COPY` (copy from another value).
An EMPTY operation sets `valueElementToReferenceId: null` and `valueElementToApplyId` to the target. The `operand` field is accepted on POST but is not echoed back in GET responses — this is expected behaviour.

**Outcomes — binding to a TABLE component (bulk action):**

Outcomes (buttons) on a TABLE are defined on the input map element, not the page element. Use `pageObjectBindingId` to tie the outcome to a specific table component, and `isBulkAction: true` to render it as a button at the top of the table rather than inline per row.

```json
{
  "developerName": "Refresh",
  "label": "Refresh",
  "nextMapElementId": "<target-map-element-id>",
  "pageObjectBindingId": "<table-page-component-id>",
  "pageActionType": "SAVE",
  "isBulkAction": true,
  "order": 0
}
```

`pageObjectBindingId` is the `id` from the page element's `pageComponents` array for the TABLE component.

**Outcomes — routing loopback paths (control points):**

When an outcome connects back to an earlier element the platform auto-generates a single midpoint control that sits on top of the intervening elements. Override `controlPoints` with a U-shape below the flow to keep the path visually clear:

```json
"controlPoints": [
  {"x": <source_center_x>, "y": <below_flow_y>},
  {"x": <target_center_x>, "y": <below_flow_y>}
]
```

- `below_flow_y` = element y + ~140 (e.g. if flow is at y:250, use y:390)
- `source_center_x` = source element x + (width / 2)
- `target_center_x` = target element x + (width / 2)

---

## Navigation Element

Defines a navigation menu displayed persistently during the flow (e.g. a sidebar).

```json
{
  "developerName": "Main Navigation",
  "label": "Navigation",
  "navigationItems": [
    {
      "developerName": "Home",
      "label": "Home",
      "locationMapElementId": "<home-map-element-id>",
      "order": 0,
      "navigationItems": []
    }
  ]
}
```

---

## Identity Provider Element

Configure authentication for a flow.

**Supported types:** `SAML`, `OIDC`, `OAUTH2`, `custom`

```json
{
  "developerName": "Boomi SSO",
  "identityProviderType": "SAML",
  "samlMetadataUrl": "https://idp.example.com/metadata.xml"
}
```
