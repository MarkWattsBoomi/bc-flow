# Package, Release & Environment API Reference

---

## Package API

Base path: `/api/package/1/`

Export and import flows as portable packages.

| Method | Path | Description |
|---|---|---|
| GET | `/package/1/flow/{id}` | Create/export flow package |
| GET | `/package/1/flow/{id}/environment/{environmentId}` | Export flow deployed in env |
| GET | `/package/1/flow/{id}/version/{versionId}` | Export specific flow version |
| GET | `/package/1/runtime/flow/{id}/{version}` | Get runtime flow package |
| GET | `/package/1/tenant` | Get tenant package |
| POST | `/package/1/tenant` | Create tenant package |
| POST | `/package/1/flow/import` | Import a flow package |
| POST | `/package/1/flow/import/token` | Import via sharing token |
| POST | `/package/1/flow/token` | Get sharing token for a flow |
| POST | `/package/1/flow/{id}/environment/{environmentId}/token` | Get env-specific token |
| POST | `/package/1/flow/{id}/version/{versionId}/token` | Get version-specific token |
| GET | `/package/1/theme/{themeName}` | Get theme package |
| POST | `/package/1/theme` | Create theme package |
| GET | `/package/1/theme/{themeName}/{environmentId}` | Get theme package for env |

---

## Release API

Base path: `/api/release/1/`

Releases bundle snapshots for deployment to environments.

| Method | Path | Description |
|---|---|---|
| GET | `/release/1/release/{id}` | Get release details |
| DELETE | `/release/1/release/{id}` | Delete release |
| POST | `/release/1/releases` | List releases (with filter body) |
| DELETE | `/release/1/release/{id}/flow/{flowId}` | Remove flow from release |
| DELETE | `/release/1/release/{id}/theme/{themeId}` | Remove theme from release |
| PUT | `/release/1/release/{id}/deploy` | Deploy release to environment |
| PUT | `/release/1/release/{id}/rollback` | Roll back a release |

**Deploy request body:**
```json
{
  "environmentId": "env-guid"
}
```

**List releases request body:**
```json
{
  "filter": {
    "flowId": "guid",
    "environmentId": "guid"
  },
  "page": 1,
  "pageSize": 25
}
```

---

## Environment API

Base path: `/api/environment/1/`

Environments are named deployment targets (e.g. Test, Production).

| Method | Path | Description |
|---|---|---|
| GET | `/environment/1` | List all environments |
| POST | `/environment/1/environment` | Create or update environment |
| GET | `/environment/1/environment/{id}` | Get environment |
| DELETE | `/environment/1/environment/{id}` | Delete test environment |
| POST | `/environment/1/environment/{id}/flows` | Get flows released to environment |
| POST | `/environment/1/environment/{id}/variable` | Save environment variable |
| POST | `/environment/1/environment/{id}/variables` | Get environment variables |
| DELETE | `/environment/1/environment/{id}/variable/{name}` | Delete environment variable |

**Environment object:**
```json
{
  "id": "guid",
  "name": "Production",
  "environmentType": "PRODUCTION"
}
```

**Environment variable:**
```json
{
  "name": "DB_URL",
  "value": "jdbc:...",
  "isEncrypted": false
}
```
