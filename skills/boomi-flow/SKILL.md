---
name: boomi-flow
description: Builds, deploys, and manages Boomi Flow applications — flows, elements (page, service, type, value, map, navigation, macro, theme), snapshots, releases, environments, states, and translations. Use when creating or modifying Boomi Flow flows and elements, managing deployments, monitoring running states, or integrating Flow with Boomi Integrate.
---

# Boomi Flow Development Skill

This skill provides CLI tools, reference documentation, and patterns for building Boomi Flow applications programmatically via the Boomi Flow REST API.

**Architecture:**
- **boomi-flow skill** — Reusable infrastructure, scripts, and reference docs
- **Project `.env`** — Credentials (never checked into source control)

**Running CLI tools:** `<skill-path>` = the directory this SKILL.md was loaded from. All script invocations use `<skill-path>/scripts/` — always substitute the real absolute path. Run from the project directory so `.env` is found correctly.

---

## First-Time Setup

**Before any Flow work:**
1. Run `bash <skill-path>/scripts/flow-env-check.sh` — verifies `.env` variables are SET
2. Run `bash <skill-path>/scripts/flow-tenant.sh --test-connection` — verifies API connectivity
3. If credentials are missing, guide the user through `/bc-flow:env-setup-guide`

---

## Documentation Architecture

**SKILL.md is the navigation hub.** Load additional reference files based on the task:

| Task | Read first | Then read |
|---|---|---|
| Any Flow work | `references/FLOW_THINKING.md` | Task-specific refs below |
| Building a flow from scratch | `FLOW_THINKING.md` | `flow_lifecycle.md` + `flow_elements_guide.md` |
| Creating/editing any element | `FLOW_THINKING.md` | `flow_elements_guide.md` |
| Linking to Boomi Integrate | `FLOW_THINKING.md` | `integrate_linking.md` |
| Deploying a flow | `flow_lifecycle.md` | — |
| Troubleshooting | `FLOW_THINKING.md` | `cli_tool_reference.md` |
| First-time user setup | `user_onboarding_guide.md` | — |
| API deep-dive | relevant `references/api/*.md` | — |

---

## Skill Repository

```
boomi-flow/                        # full skill path provided at skill load time
├── SKILL.md                       # Navigation hub (this file)
│
├── references/
│   ├── FLOW_THINKING.md           # Core mental models — ALWAYS read first
│   │
│   ├── guides/
│   │   ├── flow_lifecycle.md      # Design → Snapshot → Activate → Deploy workflow
│   │   ├── flow_elements_guide.md # All element types with JSON templates
│   │   ├── integrate_linking.md   # Connect Flow to Boomi Integrate via service elements
│   │   ├── cli_tool_reference.md  # Complete script command reference
│   │   └── user_onboarding_guide.md  # First-time .env setup and connection testing
│   │
│   └── api/
│       ├── draw.md                # Draw API — flows, elements, snapshots, assets
│       ├── admin.md               # Admin API — tenants, users, states, runtimes
│       ├── run.md                 # Run API — execution, navigation, auth, values
│       ├── package_release_environment.md  # Package/import/export + Release + Environment
│       └── monitoring_admin.md   # Dashboard, Audit, Translate, Notifications, Features, Play
│
└── scripts/                       # CLI tools — invoke as <skill-path>/scripts/<tool>.sh
    ├── flow-common.sh             # Shared utilities (sourced by all scripts)
    ├── flow-env-check.sh          # Verify .env variables are set
    ├── flow-tenant.sh             # Get tenant info / test connection
    ├── flow-list.sh               # List flows in tenant
    ├── flow-get.sh                # Get flow by ID or name
    ├── flow-create.sh             # Create or update a flow
    ├── flow-element-list.sh       # List elements by type
    ├── flow-element-get.sh        # Get element by type and ID
    ├── flow-element-create.sh     # Create or update an element (from JSON file)
    ├── flow-element-delete.sh     # Delete an element
    ├── flow-snapshot-create.sh    # Create a flow snapshot (version)
    ├── flow-snapshot-list.sh      # List snapshots for a flow
    ├── flow-snapshot-activate.sh  # Activate a snapshot
    ├── flow-package-export.sh     # Export flow as package file
    ├── flow-package-import.sh     # Import flow package
    ├── flow-release-list.sh       # List releases
    ├── flow-deploy.sh             # Deploy release to environment
    ├── flow-rollback.sh           # Roll back a release
    ├── flow-environment-list.sh   # List deployment environments
    ├── flow-environment-vars.sh   # Get/set environment variables
    ├── flow-state-list.sh         # List running flow states (admin)
    ├── flow-state-get.sh          # Get details of a specific state
    ├── flow-state-delete.sh       # Delete state(s)
    ├── flow-run.sh                # Initialize/run a flow
    ├── flow-dashboard.sh          # Flow launch metrics and error summary
    ├── flow-audit.sh              # Search audit logs / export CSV
    ├── flow-user.sh               # Tenant user management
    ├── flow-apikey.sh             # API key management
    ├── flow-translate.sh          # Translation and culture management
    └── flow-integration-list.sh   # List Boomi Integrate processes available to Flow
```

---

## Core Development Workflow

### Creating a Flow from Scratch

Read `FLOW_THINKING.md` first, then follow this order:

**1. Create the flow container**
```bash
bash <skill-path>/scripts/flow-create.sh --name "My Application"
# Save the returned flow ID
```

**2. Create elements in dependency order**
- Type elements first (data models — no dependencies)
- Value elements (reference type IDs)
- Service elements (integration points)
- Page elements (UI — reference value IDs for binding)
- Map elements (logic — reference page, service, value IDs)

For each element, create a JSON file and push it:
```bash
bash <skill-path>/scripts/flow-element-create.sh --type type --file customer-type.json
# Save returned element ID for use in dependent elements
```

**3. Update flow with start element**
```bash
bash <skill-path>/scripts/flow-create.sh --id <flow-id> --file updated-flow.json
# updated-flow.json should include startMapElementId
```

**4. Snapshot and activate**
```bash
bash <skill-path>/scripts/flow-snapshot-create.sh --flow-id <id> --name "v1.0"
bash <skill-path>/scripts/flow-snapshot-activate.sh --flow-id <id> --snapshot-id <snapshot-id>
```

**5. Deploy**
```bash
bash <skill-path>/scripts/flow-deploy.sh --list-environments
bash <skill-path>/scripts/flow-deploy.sh --release-id <release-id> --env-id <env-id>
```

### Updating an Existing Flow

1. Get the current flow and elements:
```bash
bash <skill-path>/scripts/flow-get.sh --name "My Application"
bash <skill-path>/scripts/flow-element-list.sh --type map
```

2. Edit the element JSON and push:
```bash
# Include the existing element ID in the JSON body
bash <skill-path>/scripts/flow-element-create.sh --type map --file updated-map.json
```

3. Create a new snapshot and activate:
```bash
bash <skill-path>/scripts/flow-snapshot-create.sh --flow-id <id> --name "v1.1" --comment "Fixed routing"
bash <skill-path>/scripts/flow-snapshot-activate.sh --flow-id <id> --snapshot-id <id>
```

---

## Environment Variables Required

```
FLOW_API_KEY        — API key (x-boomi-flow-api-key header)
FLOW_TENANT_ID      — Tenant ID (manywhotenant header)
FLOW_BASE_URL       — https://flow.boomi.com (or regional URL)
FLOW_VERIFY_SSL     — true (set false only for proxy SSL issues)
```

---

## Key Concepts (from FLOW_THINKING.md)

- **Flow = application container** — references elements by ID
- **Elements = building blocks** — JSON objects in the platform
- **State = one user's runtime session** — persists per user
- **Snapshot = immutable version** — like a git commit
- **Activate = make snapshot live** — required before deploy
- **Release = deployable bundle** — created by activating snapshots
- **Service element = integration bridge** — connects Flow to Boomi Integrate or external APIs

**Dependency order (create in this sequence):**
`type → value → service → page → map → flow (set startMapElementId)`

---

## Integration with Boomi Integrate

Boomi Integrate processes are called via **Service Elements** in Flow. Read `references/guides/integrate_linking.md` for the complete connection pattern.

Quick summary:
1. Ensure tenant has an Integration Account configured
2. List available processes: `bash <skill-path>/scripts/flow-integration-list.sh`
3. Create a Service element pointing to the FSS endpoint
4. Reference the service element's actions from map elements

---

## Critical Issues

1. **Wrong element dependency order** — Value elements require Type element IDs; Map elements require Page and Value element IDs. Create types and values before pages and maps.

2. **Snapshot not activated** — Creating a snapshot does not make it live. Always call `flow-snapshot-activate.sh` after creation.

3. **Editing token conflicts (HTTP 409)** — Another session has a design lock. Force-clear via the Flow platform GUI or wait for the lock to expire.

4. **Regional URLs** — EU and other regional deployments have different base URLs. Verify `FLOW_BASE_URL` if you get 404s on valid endpoints.

5. **SSL errors (curl exit 35)** — Corporate proxy (Zscaler) intercepts SSL. Set `FLOW_VERIFY_SSL=false` in `.env`.

---

## API Reference Quick Access

- **Building flows and elements:** `references/api/draw.md`
- **Tenant, users, states (admin):** `references/api/admin.md`
- **Runtime execution:** `references/api/run.md`
- **Deployment pipeline:** `references/api/package_release_environment.md`
- **Monitoring and analytics:** `references/api/monitoring_admin.md`
