# Role: users

Admin accounts with SSH keys and sudo, a password policy that PAM really enforces, and locked system accounts.

## What it does

| Concern | Change | Tag |
|---|---|---|
| Preflight | Validates admin names; refuses `users_sudo_nopasswd: false` for an admin without `password_hash` (they could never use sudo) | always |
| Admins | Creates each admin in the `admins` group, installs their keys (`exclusive`: unlisted keys are removed) | `users_admins` |
| sudo | `/etc/sudoers.d/60-hardening-admins`, validated with `visudo -cf`: group rule, `use_pty`, dedicated `/var/log/sudo.log` | `users_admins` |
| Password quality | `/etc/security/pwquality.conf.d/60-hardening.conf` (min length 14, 4 classes, dictionary check) and a check that `pam_pwquality.so` is in the PAM password stack | `users_password_policy` |
| Aging | `PASS_MAX_DAYS 365`, `PASS_MIN_DAYS 1`, `PASS_WARN_AGE 7`, `UMASK 027` in `/etc/login.defs` (new accounts) | `users_password_policy` |
| System accounts | Every account with 0 < UID < 1000 (except root, sync, shutdown, halt) gets `/usr/sbin/nologin` and a locked password | `users_system_accounts` |

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `users_admins` | `[]` | List of `{name, authorized_keys, comment, shell, groups, password_hash}` |
| `users_admin_group` | `admins` | Group that gets sudo |
| `users_sudo_nopasswd` | `true` | Key-only admins sudo without a password |
| `users_authorized_keys_exclusive` | `true` | Remove unlisted keys |
| `users_pwquality_settings` | see defaults | pwquality keys (`true` writes a bare flag) |
| `users_login_defs` | see defaults | login.defs keys |
| `users_lock_system_accounts` | `true` | Lock system accounts |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## Notes

Aging rules in `login.defs` apply to accounts created afterwards; existing accounts keep their current aging until changed with `chage`.
