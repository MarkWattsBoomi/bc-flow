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

**Minimum page element:**
```json
{
  "developerName": "Customer Form",
  "label": "Enter Customer Details",
  "pageContainers": [
    {
      "developerName": "Main",
      "label": "Customer Details",
      "containerType": "VERTICAL_FLOW",
      "order": 0,
      "pageContainers": [],
      "pageComponents": [
        {
          "developerName": "firstName",
          "label": "First Name",
          "componentType": "INPUT",
          "contentType": "ContentString",
          "isRequired": true,
          "order": 0,
          "columns": [],
          "attributes": null,
          "pageContainerDeveloperName": "Main"
        }
      ]
    }
  ]
}
```

---

## Map Element

The core logic unit. Each map element represents a step in the flow. Map elements have **Outcomes** (transitions to other map elements).

**Map element types:** `START`, `STEP`, `INPUT`, `DECISION`, `OPERATOR`, `MESSAGE`, `DATABASE_LOAD`, `DATABASE_SAVE`, `DATABASE_DELETE`, `RETURN`, `SUB_FLOW`, `WAIT`, `GROUP_REFERENCE`

**Minimum step map element:**
```json
{
  "developerName": "Show Customer Form",
  "mapElementType": "INPUT",
  "pageElementId": "<page-element-id>",
  "x": 100,
  "y": 100,
  "outcomes": [
    {
      "developerName": "Submit",
      "label": "Submit",
      "nextMapElementId": "<next-map-element-id>",
      "order": 0
    }
  ]
}
```

**Decision map element:**
```json
{
  "developerName": "Check Customer Status",
  "mapElementType": "DECISION",
  "x": 300,
  "y": 100,
  "outcomes": [
    {
      "developerName": "Active",
      "label": "Customer is active",
      "nextMapElementId": "<active-map-id>",
      "order": 0,
      "comparison": {
        "comparisonType": "AND",
        "comparisons": [
          {
            "leftValueElementToReferenceId": { "id": "<status-value-id>" },
            "criteriaType": "EQUAL",
            "rightContentValue": "active"
          }
        ]
      }
    },
    {
      "developerName": "Inactive",
      "label": "Otherwise",
      "nextMapElementId": "<inactive-map-id>",
      "order": 1
    }
  ]
}
```

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
