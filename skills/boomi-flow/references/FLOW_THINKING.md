# Boomi Flow — Core Mental Models

## What is Boomi Flow?

Boomi Flow is a low-code application platform for building user-facing applications, portals, and workflows. It is fundamentally different from Boomi Integrate:

| Boomi Integrate | Boomi Flow |
|---|---|
| Backend integration processes | Frontend + workflow applications |
| Documents flowing through shapes | Users navigating through map elements |
| XML components on a canvas | JSON elements via REST API |
| Triggered by events or schedules | Triggered by user actions in a browser |
| No persistent user state between runs | Persistent state tracks each user's journey |

## The Building Blocks

### Flow
A **Flow** is the top-level application unit. It defines the overall application and references the elements that make it up. A flow is not directly executable — it requires a **Snapshot** (version) to be activated before it can run.

### Elements (Design-time)
Elements are the reusable building blocks of a flow. Unlike Boomi Integrate components, they exist as JSON objects in the platform and are referenced by ID:

- **Map Element** — A step in the flow logic. Every user action, decision point, or integration call is a map element. Equivalent to a "shape" in Integrate but with much richer outcome routing.
- **Page Element** — The UI definition. Defines what the user sees (forms, data grids, buttons). Referenced by a map element when the flow needs to show a screen.
- **Service Element** — An integration point. Connects to an external system or Boomi Integrate process. Defines actions (methods) that can be called from map elements.
- **Type Element** — A data model definition. Defines the structure of objects used in the flow (like a Java class or JSON schema). Required before you can use typed values.
- **Value Element** — A variable. Stores data during a flow state. Can be typed (references a Type Element) or primitive (String, Number, Boolean, etc.).
- **Navigation Element** — Defines the navigation menu structure displayed to users during a flow.
- **Macro Element** — Reusable server-side logic (JavaScript) that can be called from map elements.
- **Theme Element** — Visual styling for the flow UI.
- **Tag Element** — Labels for organizing and filtering elements.
- **Group Element** — Groups of map elements for organizational purposes.
- **Identity Provider** — Authentication configuration (SAML, OIDC, OAuth).
- **Custom Page Component** — Custom UI components beyond the built-in ones.

### State (Runtime)
When a user starts a flow, a **State** is created. It represents one user's journey through the flow. States track:
- Current position (which map element the user is at)
- All value element data for this user
- Navigation history
- Authentication context

States persist until they expire, are completed, or are deleted.

## Flow Lifecycle

```
Design → Snapshot → [Release] → Deploy → Running States
```

1. **Design** — Edit elements via the Draw API or GUI. Changes are immediate but not yet versioned.
2. **Snapshot** — Capture the current design as a named, immutable version. Like a git commit.
3. **Activate Snapshot** — Mark a snapshot as the "current" version. Users running the flow see this version.
4. **Release** — Package one or more snapshots for deployment to environments.
5. **Deploy** — Push a release to a target environment (Test, Production, etc.).
6. **Running** — Users access the flow URL; states are created and managed.

## Key Development Philosophy

### JSON-first
Everything in Flow is JSON. Elements are created by POSTing JSON to the Draw API. There are no XML files, no local components. The source of truth is the platform.

### ID-based references
Elements reference each other by GUID. When building a flow programmatically:
1. Create Type elements first (data models, no dependencies)
2. Create Value elements (reference Type IDs)
3. Create Service elements (integration points)
4. Create Page elements (UI, reference Value IDs for binding)
5. Create Map elements (logic, reference Page, Service, Value IDs)
6. Create/update the Flow (reference Map element IDs)

### Editing tokens
Some Draw API calls return an `editingToken`. This token prevents concurrent modifications. If you receive an editingToken, include it in subsequent updates to the same resource.

### Service Elements and Boomi Integrate
Service elements are how Flow calls Boomi Integrate processes. The connection is through:
1. An **Integration Account** configured on the tenant (links the Flow tenant to a Boomi Integrate account)
2. A **Flow Service component** in Boomi Integrate (wraps an Integrate process)
3. A **Service element** in Flow (references the Flow Service component by URL)

The `flow-integration-list.sh` script lists available Integrate processes. The service element's `uri` field is the Flow Service endpoint URL.

## API Auth Pattern

All API calls require:
```
x-boomi-flow-api-key: {api_key}
manywhotenant: {tenant_id}
```

The `manywhotenant` header identifies which tenant to operate on. An API key can have access to multiple tenants.

## Common Mistakes

1. **Creating elements without types** — Value elements with `typeElementId` set must reference an existing Type element. Create types first.
2. **Wrong base URL** — Regional deployments use different base URLs. If the platform is EU-hosted, the URL prefix changes.
3. **Not activating a snapshot** — Creating a snapshot does not make it live. You must call activate-snapshot after creation.
4. **Deploying without a release** — You deploy a Release, not a Snapshot directly. Snapshot → create Release → deploy Release.
5. **Editing tokens** — If you get a 409 Conflict, another user (or session) has an editing lock. Wait or force-clear via the Flow platform GUI.
