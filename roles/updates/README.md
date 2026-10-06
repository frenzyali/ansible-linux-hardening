# Role: updates

Automatic security updates: unattended-upgrades on Ubuntu, dnf-automatic on Rocky Linux. Security-only and no automatic reboots by default.

## What it does

| OS | Change | Tag |
|---|---|---|
| Ubuntu | `20auto-upgrades` turns the periodic jobs on; `52unattended-upgrades-hardening` **clears** the packaged origin list (`#clear`, because apt lists add up across files) and allows only `-security` (and ESM security) origins | `updates_config` |
| Rocky | `/etc/dnf/automatic.conf`: `upgrade_type = security`, download and apply, `reboot = never` | `updates_config` |
| Both | The update timers are enabled and started | `updates_timers` |

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `updates_security_only` | `true` | `false` also installs regular bug-fix updates |
| `updates_apply` | `true` | Install, not only download |
| `updates_automatic_reboot` | `false` | Reboot when an update needs it |
| `updates_reboot_time` | `03:30` | Reboot time (Ubuntu) |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## Notes

Rocky's `upgrade_type = security` relies on the errata (updateinfo) metadata in the repositories; packages from repositories without errata data are never picked up as security updates.
