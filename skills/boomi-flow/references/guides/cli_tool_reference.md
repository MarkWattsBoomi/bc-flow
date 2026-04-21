# CLI Tool Reference

All scripts are located at `<skill-path>/scripts/`. Run from the project directory containing `.env`.

## Setup & Credentials

### flow-env-check.sh
Check which `.env` variables are SET vs UNSET.
```bash
bash <skill-path>/scripts/flow-env-check.sh
```

### flow-tenant.sh
Get tenant info or test connectivity.
```bash
bash <skill-path>/scripts/flow-tenant.sh                  # Get tenant details
bash <skill-path>/scripts/flow-tenant.sh --test-connection # Verify API connectivity
bash <skill-path>/scripts/flow-tenant.sh --update tenant.json # Update tenant settings
```

---

## Flow Management

### flow-list.sh
List flows in the tenant.
```bash
bash <skill-path>/scripts/flow-list.sh
bash <skill-path>/scripts/flow-list.sh --filter "Customer"
bash <skill-path>/scripts/flow-list.sh --active         # Only active/published flows
bash <skill-path>/scripts/flow-list.sh --page 2 --page-size 50
```

### flow-get.sh
Get a flow by ID or name.
```bash
bash <skill-path>/scripts/flow-get.sh --id <flow-id>
bash <skill-path>/scripts/flow-get.sh --name "Customer Portal"
```

### flow-create.sh
Create or update a flow.
```bash
bash <skill-path>/scripts/flow-create.sh --name "My Flow" --description "..."
bash <skill-path>/scripts/flow-create.sh --file flow.json          # Full JSON body
bash <skill-path>/scripts/flow-create.sh --id <id> --file flow.json # Update existing
```

---

## Element Management

### flow-element-list.sh
List elements of a given type.
```bash
bash <skill-path>/scripts/flow-element-list.sh --type service
bash <skill-path>/scripts/flow-element-list.sh --type page --filter "Customer"
# Types: service, page, type, value, map, navigation, macro, theme, tag, group,
#        identityprovider, customPageComponent
```

### flow-element-get.sh
Get a specific element.
```bash
bash <skill-path>/scripts/flow-element-get.sh --type service --id <element-id>
```

### flow-element-create.sh
Create or update an element (POST to Draw API).
```bash
bash <skill-path>/scripts/flow-element-create.sh --type type --file customer-type.json
bash <skill-path>/scripts/flow-element-create.sh --type page --file customer-form.json
bash <skill-path>/scripts/flow-element-create.sh --type map --file step1.json
```

### flow-element-delete.sh
Delete an element.
```bash
bash <skill-path>/scripts/flow-element-delete.sh --type page --id <element-id>
```

---

## Snapshots

### flow-snapshot-create.sh
Create a versioned snapshot of the current flow design.
```bash
bash <skill-path>/scripts/flow-snapshot-create.sh --flow-id <id> --name "v1.0.0" --comment "Initial"
```

### flow-snapshot-list.sh
List snapshots for a flow.
```bash
bash <skill-path>/scripts/flow-snapshot-list.sh --flow-id <id>
```

### flow-snapshot-activate.sh
Activate a snapshot (makes it the live version).
```bash
bash <skill-path>/scripts/flow-snapshot-activate.sh --flow-id <id> --snapshot-id <snapshot-id>
```

---

## Packages (Export/Import)

### flow-package-export.sh
Export a flow as a portable package file.
```bash
bash <skill-path>/scripts/flow-package-export.sh --flow-id <id>
bash <skill-path>/scripts/flow-package-export.sh --flow-id <id> --env-id <env-id> --output my-flow.zip
```

### flow-package-import.sh
Import a flow package.
```bash
bash <skill-path>/scripts/flow-package-import.sh --file my-flow.zip
bash <skill-path>/scripts/flow-package-import.sh --token <sharing-token>
```

---

## Release & Deployment

### flow-release-list.sh
List releases, optionally filtered by flow or environment.
```bash
bash <skill-path>/scripts/flow-release-list.sh
bash <skill-path>/scripts/flow-release-list.sh --flow-id <id>
bash <skill-path>/scripts/flow-release-list.sh --env-id <id>
```

### flow-deploy.sh
Deploy a release to an environment.
```bash
bash <skill-path>/scripts/flow-deploy.sh --list-environments
bash <skill-path>/scripts/flow-deploy.sh --release-id <id> --env-id <id>
```

### flow-rollback.sh
Roll back a release deployment.
```bash
bash <skill-path>/scripts/flow-rollback.sh --release-id <id>
```

---

## Environments

### flow-environment-list.sh
List deployment environments.
```bash
bash <skill-path>/scripts/flow-environment-list.sh
bash <skill-path>/scripts/flow-environment-list.sh --id <env-id>
```

### flow-environment-vars.sh
Get or set environment variables.
```bash
bash <skill-path>/scripts/flow-environment-vars.sh --env-id <id>
bash <skill-path>/scripts/flow-environment-vars.sh --env-id <id> --set --name DB_URL --value "jdbc:..."
bash <skill-path>/scripts/flow-environment-vars.sh --env-id <id> --set --name SECRET --value "xxx" --is-secret
bash <skill-path>/scripts/flow-environment-vars.sh --env-id <id> --delete --name DB_URL
```

---

## State Management (Admin)

### flow-state-list.sh
List running flow states.
```bash
bash <skill-path>/scripts/flow-state-list.sh
bash <skill-path>/scripts/flow-state-list.sh --flow-id <id>
```

### flow-state-get.sh
Get details of a specific state.
```bash
bash <skill-path>/scripts/flow-state-get.sh --id <state-id>
```

### flow-state-delete.sh
Delete a state or all states for a flow.
```bash
bash <skill-path>/scripts/flow-state-delete.sh --id <state-id>
bash <skill-path>/scripts/flow-state-delete.sh --flow-id <id>   # Delete all states for flow
```

---

## Runtime

### flow-run.sh
Initialize a flow execution (creates a new state).
```bash
bash <skill-path>/scripts/flow-run.sh --flow-id <id>
bash <skill-path>/scripts/flow-run.sh --flow-name "Customer Portal"
```

---

## Monitoring & Analytics

### flow-dashboard.sh
Get flow launch metrics.
```bash
bash <skill-path>/scripts/flow-dashboard.sh --flow-id <id>
bash <skill-path>/scripts/flow-dashboard.sh --tenant          # Tenant-wide metrics
bash <skill-path>/scripts/flow-dashboard.sh --errors          # State error summary
```

### flow-audit.sh
Search audit logs.
```bash
bash <skill-path>/scripts/flow-audit.sh
bash <skill-path>/scripts/flow-audit.sh --type "FLOW_DEPLOYED" --from "2026-01-01"
bash <skill-path>/scripts/flow-audit.sh --csv --output audit.csv
```

---

## Users & API Keys

### flow-user.sh
Manage tenant users.
```bash
bash <skill-path>/scripts/flow-user.sh --list
bash <skill-path>/scripts/flow-user.sh --me
bash <skill-path>/scripts/flow-user.sh --add --email user@example.com
bash <skill-path>/scripts/flow-user.sh --remove --id <user-id>
```

### flow-apikey.sh
Manage API keys for the current user.
```bash
bash <skill-path>/scripts/flow-apikey.sh --list
bash <skill-path>/scripts/flow-apikey.sh --create --name "CI Key"
bash <skill-path>/scripts/flow-apikey.sh --delete --name "old-key"
```

---

## Translations

### flow-translate.sh
Manage flow translations and cultures.
```bash
bash <skill-path>/scripts/flow-translate.sh --list-cultures
bash <skill-path>/scripts/flow-translate.sh --get-flow --flow-id <id>
bash <skill-path>/scripts/flow-translate.sh --export --flow-ids <id1,id2> --output translations.json
bash <skill-path>/scripts/flow-translate.sh --import --file translations.json
```

---

## Integration Discovery

### flow-integration-list.sh
List Boomi Integrate processes available as Flow services.
```bash
bash <skill-path>/scripts/flow-integration-list.sh
bash <skill-path>/scripts/flow-integration-list.sh --account-id <id>
bash <skill-path>/scripts/flow-integration-list.sh --properties --account-id <id> --process-id <pid>
```
