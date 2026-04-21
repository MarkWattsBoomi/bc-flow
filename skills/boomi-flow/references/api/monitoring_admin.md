# Dashboard, Audit, Translate & Supporting APIs

---

## Dashboard API

Base path: `/api/dashboard/1/`

| Method | Path | Description |
|---|---|---|
| GET | `/dashboard/1/flow/{id}` | Get launch metrics for a flow |
| POST | `/dashboard/1/flows` | Get metrics for multiple flows |
| GET | `/dashboard/1/flows` | Get tenant-wide launch metrics |
| GET | `/dashboard/1/stateErrors` | List state errors (paginated) |
| GET | `/dashboard/1/stateErrorsLineChart` | State errors as line chart data |
| GET | `/dashboard/1/stateErrorsPieChart` | State errors as pie chart data |

---

## Audit API

Base path: `/api/audit/1/`

| Method | Path | Description |
|---|---|---|
| GET | `/audit/1/search` | Search audit events |
| GET | `/audit/1/csv` | Export audit log as CSV |

**Search query parameters:**
- `type` — filter by event type (e.g. `FLOW_DEPLOYED`, `USER_ADDED`)
- `from` — ISO 8601 start date
- `to` — ISO 8601 end date
- `page`, `pageSize`

---

## Translate API

Base path: `/api/translate/1/`

### Cultures

| Method | Path | Description |
|---|---|---|
| POST | `/translate/1/culture` | Create or update culture |
| GET | `/translate/1/culture` | List cultures |
| GET | `/translate/1/culture/{id}` | Get culture |
| DELETE | `/translate/1/culture/{id}` | Delete culture |
| GET | `/translate/1/cultures` | List all available cultures |
| GET | `/translate/1/default-culture` | Get default culture |

### Flow Translations

| Method | Path | Description |
|---|---|---|
| GET | `/translate/1/flow/{id}` | List translations for a flow |
| GET | `/translate/1/flow/{id}/translation/{cultureId}` | Get flow translation for culture |
| POST | `/translate/1/flows/export` | Export translations (multiple flows) |
| POST | `/translate/1/flows/import` | Import translations |
| GET | `/translate/1/{flowId}/translations` | Get flow translations |

### Element Translations (per element type)

Applies to: `map`, `navigation`, `page`, `type`, `value`

| Method | Path | Description |
|---|---|---|
| POST | `/translate/1/{type}/{id}` | Update translation for element |
| GET | `/translate/1/{type}/{id}/translation/{cultureId}` | Get translation for element |

---

## Notifications API

Base path: `/api/notifications/1/`

| Method | Path | Description |
|---|---|---|
| GET | `/notifications/1/notification` | List all notifications |
| GET | `/notifications/1/user/notification` | List current user's notifications |
| GET | `/notifications/1/user/notification/{id}` | Get specific notification |
| POST | `/notifications/1/user/notification/read` | Mark all notifications as read |

---

## Features API

Base path: `/api/features/1/`

| Method | Path | Description |
|---|---|---|
| GET | `/features/1/features` | List all available feature flags |
| GET | `/features/1/tenant` | Get tenant's feature flag settings |
| PUT | `/features/1/tenant/{id}` | Update a tenant feature flag |

---

## Play API (Players)

Base path: `/api/play/1/`

Players are customised flow runtime environments.

| Method | Path | Description |
|---|---|---|
| GET | `/play/1/player` | Get players |
| GET | `/play/1/players` | List players |
| GET | `/play/1/player/{id}` | Get specific player |
| POST | `/play/1/player/{id}` | Update player |
| DELETE | `/play/1/player/{id}` | Delete player |

---

## Service Invoker API

Base path: `/api/service/1/`

Track service calls made during flow execution.

| Method | Path | Description |
|---|---|---|
| GET | `/service/1/invoker` | List invoker requests |
| GET | `/service/1/invoker/{id}` | Get invoker request |
| GET | `/service/1/invoker/flow/{flowId}` | List requests for a flow |
| GET | `/service/1/invoker/flow/{flowId}/version/{versionId}` | List by flow version |
| GET | `/service/1/invoker/state/{stateId}` | List requests in a state |

---

## Insights API

| Method | Path | Description |
|---|---|---|
| POST | `/insights/1/outcomeevent` | Post an outcome event (analytics) |

---

## Identity Provider

| Method | Path | Description |
|---|---|---|
| GET | `/identityprovider/1/{tenantId}/{id}/saml/metadata` | Get SAML metadata XML |
