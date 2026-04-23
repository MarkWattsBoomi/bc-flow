# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

**bc-flow** is a Claude Code plugin that provides the `bc-flow:boomi-flow` skill for building and managing Boomi Flow applications. It ships:

- **28 CLI scripts** in `skills/boomi-flow/scripts/` — bash wrappers around the Flow REST API
- **Reference documentation** in `skills/boomi-flow/references/` — API references, lifecycle guides, element templates
- **Two user commands** in `commands/` — interactive setup guides
- **A workspace template** in `template/` — files copied into new Flow project workspaces

The plugin has no build system, no tests, and no compiled output. All source is bash scripts and markdown.

## Architecture

### Skills

`skills/boomi-flow/` is the only skill. It contains:

- `SKILL.md` — the skill entrypoint document loaded into context when the skill is invoked
- `scripts/` — executable bash scripts (one per API operation)
- `references/` — markdown docs loaded selectively during skill use

### Scripts

All scripts share a common pattern:

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"
load_env; require_env FLOW_API_KEY FLOW_TENANT_ID FLOW_BASE_URL
```

`flow-common.sh` provides:
- `load_env()` / `require_env()` — credential loading and validation
- `flow_api METHOD PATH [body]` — authenticated API call; sets `$RESPONSE_BODY` and `$RESPONSE_CODE` globals
- `flow_curl()` — low-level curl with auth headers (`x-boomi-flow-api-key`, `manywhotenant`)
- `build_flow_url()` — constructs full API URLs from `$FLOW_BASE_URL`
- Activity logging to `.activity-log/`

### Reference documentation

```
skills/boomi-flow/references/
├── FLOW_THINKING.md              # Core mental models — read this first
├── guides/
│   ├── flow_lifecycle.md         # Design → Snapshot → Activate → Release → Deploy
│   ├── flow_elements_guide.md    # JSON templates for all 12 element types
│   ├── integrate_linking.md      # Connecting Flow to Boomi Integrate via Service elements
│   ├── cli_tool_reference.md     # Reference for all scripts
│   └── user_onboarding_guide.md  # First-time credential setup
└── api/
    ├── draw.md                   # Flows, elements, snapshots (Draw API)
    ├── admin.md                  # Tenants, users, states, runtimes
    ├── run.md                    # Execution, navigation, auth
    ├── package_release_environment.md
    └── monitoring_admin.md       # Dashboard, audit, translate, notifications, play
```

### Commands

`commands/env-setup-guide.md` and `commands/new-project.md` are markdown files that define interactive Claude Code commands. They guide users through credential setup and workspace scaffolding respectively.

### Template

`template/` contains files that the `new-project` command copies into user workspaces: `.env.example`, `CLAUDE.md`, `.gitignore`.

### Plugin registration

`.claude-plugin/plugin.json` — plugin metadata. `.claude-plugin/marketplace.json` — marketplace schema for Claude Code discovery.

## Key Flow API constraints

These are non-obvious and affect all script and documentation work:

- **No PUT endpoints** — the Flow API is POST-only; updates use POST to the same endpoint as creation
- **No DELETE for most elements** — elements are soft-deleted or replaced
- **Two-pass map element creation** — map elements must be created before outcomes (outcomes reference other map element IDs that may not exist yet)
- **Editing tokens** — `POST /element/{id}/editing-token` acquires a design lock; HTTP 409 means another session holds it
- **Auth headers** — `x-boomi-flow-api-key` and `manywhotenant` (not Bearer/Authorization)
- **Element IDs are UUIDs** — assigned by the platform on creation; scripts capture them from response JSON

## Extending the plugin

**Adding a new script:**
1. Create `skills/boomi-flow/scripts/flow-<verb>-<noun>.sh`
2. Source `flow-common.sh`, call `load_env` and `require_env`
3. Use `flow_api` for all HTTP calls — never call `curl` directly
4. Add an entry to `skills/boomi-flow/references/guides/cli_tool_reference.md`

**Adding new API reference:**
- Add to the appropriate file under `skills/boomi-flow/references/api/`
- Update `SKILL.md` if the reference should be surfaced to the skill agent

**Updating the workspace template:**
- Edit `template/CLAUDE.md` — this is what user workspaces get, not this file
- Edit `template/.env.example` for new required credentials

## Credentials for local testing

The `.env` file (gitignored) holds:

```
FLOW_API_KEY=...
FLOW_TENANT_ID=...
FLOW_BASE_URL=https://flow.boomi.com   # or regional URL
FLOW_VERIFY_SSL=true
```

Test connectivity: `bash skills/boomi-flow/scripts/flow-tenant.sh --test-connection`
Verify credentials: `bash skills/boomi-flow/scripts/flow-env-check.sh`
