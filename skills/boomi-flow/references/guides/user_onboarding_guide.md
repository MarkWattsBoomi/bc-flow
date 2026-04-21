# User Onboarding Guide

## First-Time Setup

### Step 1: Prerequisites

Ensure you have the following tools installed:
- `curl` (for API calls)
- `jq` (for JSON processing)

Test:
```bash
curl --version
jq --version
```

### Step 2: Create Your .env File

Copy `.env.example` to `.env` in your project directory:
```bash
cp .env.example .env
```

Edit `.env` and fill in:

**`FLOW_API_KEY`**
Go to the Boomi Flow platform → click your user avatar (top right) → API Keys → New API Key. Give it a name and copy the generated key value.

**`FLOW_TENANT_ID`**
In the Boomi Flow platform URL, your tenant ID appears as the GUID segment. For example, in:
`https://flow.boomi.com/tenant/abc12345-def6-7890-...`
The tenant ID is `abc12345-def6-7890-...`

Alternatively: Settings → Tenant → copy the Tenant ID field.

**`FLOW_BASE_URL`**
- Standard (US): `https://flow.boomi.com`
- EU: `https://eu.flow.boomi.com`
- Custom/private: provided by your platform admin

**`FLOW_VERIFY_SSL`**
Leave as `true` unless your organisation uses a proxy (like Zscaler) that intercepts SSL. Only set `false` if you get SSL errors.

### Step 3: Verify Setup

```bash
bash <skill-path>/scripts/flow-env-check.sh
```

All variables should show SET.

### Step 4: Test Connection

```bash
bash <skill-path>/scripts/flow-tenant.sh --test-connection
```

Expected output:
```
Testing connection to Boomi Flow platform...
Connection successful
Tenant: Your Tenant Name
Tenant ID: abc12345-def6-7890-...
```

### Troubleshooting

| Error | Likely cause | Fix |
|---|---|---|
| `curl: (35) SSL connect error` | Corporate proxy (Zscaler) | Set `FLOW_VERIFY_SSL=false` |
| HTTP 401 | Invalid API key | Regenerate in Flow platform |
| HTTP 403 | API key lacks tenant access | Ensure key has access to the tenant |
| HTTP 404 on tenant | Wrong tenant ID | Double-check FLOW_TENANT_ID |
| `.env file not found` | Running from wrong directory | Run scripts from your project root |
