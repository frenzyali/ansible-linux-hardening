# Role: auditd

auditd with rules for the events an investigator asks about first: who changed accounts or sudo rights, who logged in, who changed the clock, who loaded a kernel module, and who ran a privileged command.

## What it does

| Concern | Change | Tag |
|---|---|---|
| Daemon | `auditd.conf`: 32 MB files, 8 kept, rotate; on low or full disk, report and suspend instead of halting | `auditd_config` |
| Rules | `/etc/audit/rules.d/50-hardening.rules`: identity files (`identity`), sudoers and sudo log (`scope`, `sudo_log`), logins and auth log (`logins`, `auth_log`), sshd config, time-changing syscalls (`time-change`), module syscalls and tools (`modules`), chmod/chown/xattr and mounts by real users (`perm_mod`, `mounts`) | `auditd_rules` |
| Privileged commands | One rule per setuid/setgid binary **found on that host** (`privileged`), so new binaries are covered on the next run | `auditd_rules` |
| Immutable | `99-finalize.rules` with `-e 2`: rules cannot be changed or switched off until reboot | `auditd_rules` |
| Load | `augenrules --load`; if the running rules are already immutable, the handler says a reboot is needed instead of failing | handlers |

Syscall rules are written for `b64` and `b32` on x86_64, and `b64` only elsewhere (names that do not exist on aarch64 are left out).

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `auditd_immutable` | `true` | Lock rules until reboot |
| `auditd_rules_*` | `true` | Toggle each rule group |
| `auditd_rules_extra` | `[]` | Raw extra rule lines |
| `auditd_conf` | see defaults | auditd.conf keys |
| `auditd_uid_min` | `1000` | "Real user" threshold for `auid` filters |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## In containers

The kernel audit subsystem is not available in a container, so with `hardening_in_container: true` auditd is enabled but not started and the rules are not loaded. The tests check the rule files instead.
