# Role: ssh

A fully templated `sshd_config` that is validated with `sshd -t` before it replaces the live file, and a lockout guard that refuses to turn password logins off unless an admin can still get in with a key.

## What it does

| Concern | Change | Tag |
|---|---|---|
| Lockout guard | Runs first. Fails the play with `LOCKOUT PROTECTION` unless a non-root user from `ssh_lockout_guard_users` has a non-empty `authorized_keys` on the host and is allowed by AllowUsers/AllowGroups. In check mode, keys declared in variables also count | `ssh_lockout_guard`, `ssh_config` |
| Install | openssh server and client, missing host keys (`ssh-keygen -A`), privilege separation directory | `ssh_config` |
| sshd_config | No root login, keys only, no keyboard-interactive, `MaxAuthTries 3`, `LoginGraceTime 30`, AllowUsers, no forwarding/X11/tunnels, `ClientAlive` 300 s x 2, `LogLevel VERBOSE`, banner, `internal-sftp`, modern KEX/ciphers/MACs | `ssh_config` |
| Drop-ins | `Include sshd_config.d/*.conf` comes **after** the hardened settings, so cloud-init or distro drop-ins cannot weaken them (sshd keeps the first value) | `ssh_config` |
| Apply | Reload sshd (sessions survive); on Ubuntu 24.04 also `daemon-reload` and restart `ssh.socket`, since socket activation takes its port from sshd_config through a generator | handlers |
| Idle shells | `TMOUT=900` in `/etc/profile.d/60-hardening-tmout.sh` | `ssh_idle_timeout` |

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `ssh_port` | `22` | Listen port (the firewall and fail2ban roles follow it) |
| `ssh_password_authentication` | `false` | Guarded by the lockout check |
| `ssh_allow_users` | names from `users_admins` | AllowUsers (empty: no directive) |
| `ssh_allow_groups` | `[]` | AllowGroups |
| `ssh_lockout_guard_users` | `users_admins` | Who the guard checks |
| `ssh_max_auth_tries` | `3` | MaxAuthTries |
| `ssh_client_alive_interval` / `_count_max` | `300` / `2` | Dead-connection timeout |
| `ssh_shell_timeout` | `900` | TMOUT for interactive shells (0 disables) |
| `ssh_ciphers`, `ssh_macs`, `ssh_kex_algorithms` | see defaults | Allowed algorithms |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## Notes

- `ClientAliveInterval` drops dead or unresponsive connections; an idle but healthy client still answers keepalives, which is why the shell `TMOUT` exists as well.
- A previous `sshd_config` is kept as a timestamped backup next to the file whenever it changes.
- On Rocky Linux with SELinux enforcing, a non-default `ssh_port` also needs `semanage port -a -t ssh_port_t -p tcp <port>` (not automated yet).
