# Admin API Reference

Base path: `/api/admin/`

## Tenant

| Method | Path | Description |
|---|---|---|
| GET | `/admin/1/tenant` | Get current tenant details |
| POST | `/admin/1/tenant` | Update tenant settings |
| DELETE | `/admin/1/tenant` | Delete tenant |
| GET | `/admin/1/runtime/tenant` | Get tenant (MCR/local runtime) |
| DELETE | `/admin/1/tenant/data` | Delete all tenant data |
| POST | `/admin/1/tenant/expiry` | Update tenant expiry date |
| GET | `/admin/1/tenant/subtenants` | List sub-tenants |
| POST | `/admin/1/tenant/subtenants` | Create sub-tenant |
| GET | `/admin/1/tenant/runtimes` | List runtimes for tenant |

**Tenant object key fields:**
```json
{
  "id": "guid",
  "developerName": "Tenant Name",
  "tenantSettings": {
    "storageType": "default",
    "idleStateExpirationTime": 3600,
    "stateExpirationTime": 86400
  }
}
```

## Integration Account

| Method | Path | Description |
|---|---|---|
| GET | `/admin/1/tenant/integrationaccount` | Get linked Integration account |
| POST | `/admin/1/tenant/integrationaccount` | Update Integration account link |
| POST | `/admin/1/tenant/integrationaccount/validate` | Validate Integration credentials |
| GET | `/admin/1/tenant/integrationaccount/environments` | Get Integration environments |

## States

| Method | Path | Description |
|---|---|---|
| GET | `/admin/1/states` | List all states (paginated) |
| DELETE | `/admin/1/states` | Delete multiple states (with filter) |
| GET | `/admin/1/states/{id}` | Get specific state |
| DELETE | `/admin/1/states/{id}` | Delete specific state |
| GET | `/admin/1/states/flow` | List states grouped by flow |
| GET | `/admin/1/states/flow/{id}` | List states for a flow |
| GET | `/admin/1/states/flow/{id}/{version}` | List states for a flow version |
| GET | `/admin/1/documents/{stateId}/download/{fileId}/{filename}` | Download state document |

**State object key fields:**
```json
{
  "id": "guid",
  "flowName": "string",
  "flowVersionId": "guid",
  "currentMapElementName": "string",
  "currentRunningUserEmail": "string",
  "dateModified": "ISO8601",
  "externalId": "string",
  "isActive": true
}
```

## Users

| Method | Path | Description |
|---|---|---|
| GET | `/admin/1/users` | List tenant users |
| POST | `/admin/1/users` | Add user to tenant |
| GET | `/admin/1/users/{id}` | Get user |
| PUT | `/admin/1/users/{id}` | Update user |
| DELETE | `/admin/1/users/{id}` | Remove user from tenant |
| GET | `/admin/1/users/me` | Get current user |
| PUT | `/admin/1/users/me` | Update current user |
| GET | `/admin/1/users/me/settings` | Get current user tenant settings |
| PUT | `/admin/1/users/me/settings` | Update current user tenant settings |
| GET | `/admin/1/users/me/user-settings` | Get user-level settings |
| POST | `/admin/1/users/me/user-settings` | Update user-level settings |

## API Keys

| Method | Path | Description |
|---|---|---|
| POST | `/admin/1/users/me/keys` | Create API key |
| GET | `/admin/1/users/me/keys` | List API keys |
| DELETE | `/admin/1/users/me/keys/{name}` | Delete API key |

## Runtimes (Organization)

| Method | Path | Description |
|---|---|---|
| GET | `/admin/1/organization/runtimes` | List organization runtimes |
| POST | `/admin/1/organization/runtimes` | Create runtime |
| GET | `/admin/1/organization/runtimes/{id}` | Get runtime |
| PUT | `/admin/1/organization/runtimes/{id}` | Update runtime |
| DELETE | `/admin/1/organization/runtimes/{id}` | Delete runtime |
| GET | `/admin/1/organization/runtimes/{id}/failures` | List runtime failures |

## Provisioning

| Method | Path | Description |
|---|---|---|
| POST | `/admin/1/provisioning` | Provision a new tenant |
| POST | `/admin/2/provisioning` | Provision tenant (v2) |
