---
description: Scaffold a new Boomi Flow project workspace in the current directory
---

Set up a new Boomi Flow project workspace. The `boomi-flow` skill must be loaded — the scripts directory and template files come from the skill, not this workspace.

## Steps

1. **Audit the current directory**:
   - Check whether `.env`, `CLAUDE.md`, `.gitignore`, and `flows/` already exist
   - Report what will be created vs what will be skipped (never overwrite existing files)

2. **Create `.env`** (skip if already present):
   - Write a `.env` file using the content of `template/.env.example` from the skill base path
   - Inform the user they need to fill in `FLOW_API_KEY`, `FLOW_TENANT_ID`, and (if applicable) `FLOW_BASE_URL`

3. **Create `CLAUDE.md`** (skip if already present):
   - Write a `CLAUDE.md` file using the content of `template/CLAUDE.md` from the skill base path

4. **Create `.gitignore`** (skip if already present):
   - Write a `.gitignore` file using the content of `template/.gitignore` from the skill base path

5. **Create `flows/` directory** (skip if already present):
   - Create a `flows/` subdirectory for storing exported flow packages

6. **Check credentials**:
   - Run `bash <skill-path>/scripts/flow-env-check.sh` to show which variables are SET vs UNSET
   - If all are SET: run `bash <skill-path>/scripts/flow-tenant.sh --test-connection` to verify platform connectivity
   - If any are UNSET: tell the user to fill in `.env`, then offer to walk them through `/bc-flow:env-setup-guide`

7. **Confirm and hand off**:
   - List every file and directory created (or skipped)
   - Confirm platform connectivity status
   - Ask: "What would you like to build?"

## Notes

- This command is idempotent — safe to run in a partially-set-up project
- Never overwrite files that already exist; always skip and notify
- If curl returns exit code 35 during the connection test, alert the user to check Zscaler or corporate VPN
