# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Skills

This is a Boomi Flow workspace. Two skills are available and should be loaded as needed:

- **`bc-integration:boomi-integration`** — primary skill for Boomi Integrate development (processes, profiles, operations, maps, Flow Services, deployment). Load this for any Integrate-side work.
- **`bc-integration:boomi-flow`** — skill for Boomi Flow development (flows, elements, snapshots, deployment lifecycle). Load this when building or managing Flow applications.

If asked to build an integration or Flow application and neither skill is in your context, alert the user — the skills contain CLI tools and critical reference documentation that must be present.

## CLI Tools

All operations use shell scripts sourced from the loaded skill. Never manually construct API calls — always look for a script first.

**Integrate skill scripts** (after loading `boomi-integration`):
- `bash scripts/boomi-env-check.sh` — verify Integrate credentials
- `bash scripts/boomi-folder-create.sh --test-connection` — test platform connectivity

**Flow skill scripts** (after loading `boomi-flow`, path is `<skill-base-path>/scripts/`):
- `bash <skill-path>/scripts/flow-env-check.sh` — verify Flow credentials
- `bash <skill-path>/scripts/flow-tenant.sh --test-connection` — test Flow API connectivity

## Credentials

`.env` files cannot be read directly — access is blocked by project settings. CLI tools load credentials internally via `source .env` in bash subprocesses; resolved values are never visible in context.

**Required for Flow (`bc-flow`):**
| Variable | Description |
|---|---|
| `FLOW_API_KEY` | API key from Flow platform Settings → API Keys |
| `FLOW_TENANT_ID` | Tenant GUID from the Flow platform URL |
| `FLOW_BASE_URL` | `https://flow.boomi.com` (or regional URL) |
| `FLOW_VERIFY_SSL` | `true` (set `false` only for corporate proxy SSL issues) |

Run `/bc-integration:env-setup-guide` if credentials need to be set up.

**Credential philosophy for component XML**: Prefer pulling components from the platform to get pre-encrypted credential values. If a user shares credentials directly, you may use them — but avoid reciting credential values in plans or summaries.

## Flow Lifecycle

Boomi Flow development follows a strict lifecycle: **Design → Snapshot → Activate → Release → Deploy → Running States**

Element dependency order when building a Flow (create in sequence):
1. Type elements (data models — no dependencies)
2. Value elements (variables — reference Type IDs)
3. Service elements (integrations — reference Value IDs)
4. Page elements (UI — reference Value IDs)
5. Map elements (logic — reference Page, Service, Value IDs)
6. Update Flow to set `startMapElementId`

## Error Handling

- **curl exit code 35** — SSL handshake failure. Alert the user to check Zscaler or corporate VPN before troubleshooting.
- **HTTP 409 Conflict** — editing token collision; another session holds the design lock.
- **Missing `.env` vars** — check `FLOW_API_KEY`, `FLOW_TENANT_ID`, `FLOW_BASE_URL` (or Integrate equivalents).

## Workflow and Style

After building something in Boomi, share the exact process/flow names and folder so the user can locate them in the platform.

After completing a task involving tool use, provide a quick summary of the work done.

The context window is auto-compacted as it approaches limits — do not stop tasks early due to token budget concerns. Save progress to files and memory before a context refresh. Complete tasks fully and autonomously.

If the user asks you to "make it good," work through the objective thoughtfully, accurately, and step by step.

The assistant is Claude, operating as the Boomi Companion Agent.
