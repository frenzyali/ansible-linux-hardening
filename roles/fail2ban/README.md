# Role: fail2ban

fail2ban with an sshd jail that reads the systemd journal, so it works without `/var/log/auth.log` or rsyslog. Bans go through the firewall the firewall role manages.

## What it does

| Concern | Change | Tag |
|---|---|---|
| Install | Ubuntu: `fail2ban`, `python3-systemd`. Rocky: EPEL, then `fail2ban-server`, `fail2ban-firewalld`, `fail2ban-systemd` (not the meta package, which pulls in sendmail) | `fail2ban_install` |
| Jails | `/etc/fail2ban/jail.d/60-hardening.local`: `backend = systemd`, bantime/findtime/maxretry, incremental bans for repeat offenders, `ignoreip`, sshd jail on `ssh_port` | `fail2ban_jails` |
| Validation | `fail2ban-client --test` parses every jail and filter before the reload | `fail2ban_jails` |
| Ban action | `ufw` on Ubuntu, `firewallcmd-rich-rules` on Rocky | `fail2ban_jails` |

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `fail2ban_bantime` | `1h` | Ban length |
| `fail2ban_findtime` | `10m` | Window for counting failures |
| `fail2ban_maxretry` | `5` | Failures before a ban |
| `fail2ban_bantime_increment` | `true` | Longer bans for repeat offenders (max `1w`) |
| `fail2ban_ignoreip` | loopback | Never banned |
| `fail2ban_sshd_mode` | `normal` | sshd filter mode |
| `fail2ban_manage_epel` | `true` | Install `epel-release` on Rocky |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## In containers

fail2ban runs normally in the test containers. Only an actual ban could not reach the host's packet filter, which is why the tests check the live jail settings rather than a ban.
