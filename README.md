# bc-flow

Boomi Flow development tools for Claude Code — skills and commands for building, deploying, and managing Boomi Flow applications via the Boomi Flow REST API.

## What's included

- **`boomi-flow` skill** — AI agent skill for building and managing Flow applications
- **`/bc-flow:env-setup-guide`** — Interactive credential setup command
- **CLI scripts** — Shell scripts for all common Flow API operations
- **Reference documentation** — Element templates, lifecycle guides, API reference

## Skill capabilities

The `boomi-flow` skill enables an AI agent to:

- Create and manage flows and all element types (page, service, type, value, map, navigation, macro, theme, tag, group, identity provider, custom page component)
- Manage the full deployment lifecycle: snapshot → activate → release → deploy
- Export/import flow packages
- Manage running states and audit logs
- Link Flow to Boomi Integrate via service elements
- Manage users, API keys, environments, and translations

## Setup

1. Copy `template/.env.example` to your project directory as `.env`
2. Fill in your credentials (see `/bc-flow:env-setup-guide` for help finding them)
3. Run `bash <skill-path>/scripts/flow-env-check.sh` to verify
4. Run `bash <skill-path>/scripts/flow-tenant.sh --test-connection` to test

## Required credentials

| Variable | Description |
|---|---|
| `FLOW_API_KEY` | API key from Flow platform Settings → API Keys |
| `FLOW_TENANT_ID` | Tenant GUID from the Flow platform URL |
| `FLOW_BASE_URL` | `https://flow.boomi.com` (or regional URL) |
| `FLOW_VERIFY_SSL` | `true` (set `false` only for corporate proxy SSL issues) |

## Prerequisites

- `curl`
- `jq`

## Scripts

See `skills/boomi-flow/references/guides/cli_tool_reference.md` for full script documentation.

## Version

0.1.0
