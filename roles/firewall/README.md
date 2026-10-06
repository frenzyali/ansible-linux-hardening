# Role: firewall

Default-deny inbound firewall with an allowlist: ufw on Ubuntu, firewalld on Rocky Linux. SSH is always allowed, and it is allowed before the firewall is switched on.

## What it does

| Backend | Change | Tag |
|---|---|---|
| ufw | `/etc/default/ufw`: input and forward `DROP`, output `ACCEPT`, IPv6 on; SSH as a rate-limited (`limit`) rule; listed ports allowed; `LOGLEVEL=low`; `ufw enable` | `firewall_rules` |
| firewalld | Zone `public` (default): SSH and listed ports, `cockpit` removed, target `default` (rejects unlisted traffic, keeps ICMP for path-MTU and IPv6 neighbour discovery); enabled at boot | `firewall_rules` |

The ufw default policies are written with `lineinfile`: the ufw module cannot detect a policy change while ufw is inactive, so this keeps `--check --diff` honest. firewalld rules use `offline: true`, which uses `firewall-offline-cmd` when the daemon is down and the live daemon otherwise, so the same tasks write the permanent configuration in both cases.

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `firewall_ssh_port` | `ssh_port` or 22 | Always allowed |
| `firewall_allowed_ports` | `[]` | `{port, proto, comment}` entries |
| `firewall_ufw_ssh_rule` | `limit` | `limit` or `allow` |
| `firewall_firewalld_zone` | `public` | Zone to manage |
| `firewall_firewalld_services_remove` | `[cockpit]` | Pre-enabled services to remove |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## In containers

With `hardening_in_container: true` the configuration is written but ufw is not enabled and firewalld is not started: a container does not own the host's packet filter.
