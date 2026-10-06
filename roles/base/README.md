# Role: base

Baseline packages, client-only time sync, a persistent journal, a neutral login banner, and removal of legacy clients and unneeded services.

## What it does

| Concern | Change | Tag |
|---|---|---|
| Packages | Installs `chrony`, `sudo`, `ca-certificates` (+ `base_packages_extra`); removes telnet, rsh, talk, NIS, tftp, ftp, xinetd if present | `base_packages` |
| Time sync | chrony as a client only (`port 0`, `cmdport 0`), config validated with `chronyd -p`; distro pool unless `base_chrony_sources` is set | `base_time` |
| journald | `/etc/systemd/journald.conf.d/60-hardening.conf`: `Storage=persistent`, compressed, size and age capped | `base_journald` |
| Banner | `/etc/issue` and `/etc/issue.net` with a warning and no OS/version details (used by the ssh role) | `base_banner` |
| Services | Stops, disables and **masks** avahi, cups and rpcbind (service and socket units) if installed | `base_services` |

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `base_enabled` | `true` | Run the role |
| `base_packages_extra` | `[]` | Extra packages to install |
| `base_packages_absent_extra` | `[]` | Extra packages to remove |
| `base_chrony_sources` | `[]` (distro pool) | chrony source lines |
| `base_journald_settings` | persistent, 1G, 3 months | `[Journal]` keys |
| `base_banner_text` | short warning | Banner text |
| `base_services_disabled` | avahi, cups, rpcbind | Units to mask if they exist |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## In containers

With `hardening_in_container: true` chronyd is configured and enabled but not started (it needs `CAP_SYS_TIME`).
