---
description: Interactive guide for setting up Boomi Flow platform credentials
---

Guide the user through setup or re-setup of their `.env` file for Boomi Flow API access.

## Steps

1. **Check current state**:
   - Ensure the `boomi-flow` skill is loaded (the `scripts/` directory comes from the skill)
   - Run `bash <skill-path>/scripts/flow-env-check.sh` to see which variables are SET vs UNSET
   - Run `bash <skill-path>/scripts/flow-tenant.sh` to test platform connectivity
   - Inform user of current state

2. **Ask user what they want**:
   - Options:
     - "Create/recreate .env file with Boomi Flow credentials"
     - "Test connection to Boomi Flow platform"
     - "Explain the credential fields"

3. **For credential setup**:
   - Have the user copy `.env.example` to a new file named `.env` using a text editor or IDE
   - Explain each value and where to find it:

   - `FLOW_API_KEY` — "In the Boomi Flow platform, go to your user menu (top right) → API Keys → Generate a new key. Copy the key value."
   - `FLOW_TENANT_ID` — "In the Flow platform URL, the tenant ID appears as the GUID segment after `/tenant/`. Alternatively, in Settings → Tenant, it is displayed as the Tenant ID."
   - `FLOW_BASE_URL` — "Leave as `https://flow.boomi.com` unless you are on a regional deployment (e.g. EU: `https://eu.flow.boomi.com`)."
   - `FLOW_VERIFY_SSL` — "Leave as `true` unless behind a corporate proxy that intercepts SSL (e.g. Zscaler). Set to `false` only if curl returns SSL errors."

   You will not be able to write credentials into `.env` yourself due to default project settings.

4. **Confirm completion**:
   - Run `bash <skill-path>/scripts/flow-env-check.sh` to verify variables are SET
   - Run `bash <skill-path>/scripts/flow-tenant.sh` to verify API connectivity
   - If success, ask: "What would you like to build?"
   - If failure, check: SSL errors → suggest `FLOW_VERIFY_SSL=false` or Zscaler check; 401 → API key incorrect; 404 → wrong tenant ID

## Notes

- Can be run multiple times for re-setup
- The agent helps users *find* credentials but does not write them to `.env` — the user edits the file themselves
- If curl returns exit code 35, alert the user to check Zscaler or corporate VPN
