# Role: kernel

sysctl hardening in a drop-in file, kernel modules that cannot be loaded, and no core dumps.

## What it does

| Concern | Change | Tag |
|---|---|---|
| sysctl | `/etc/sysctl.d/60-hardening.conf`: `kptr_restrict=2`, `dmesg_restrict=1`, `perf_event_paranoid=3`, ASLR 2, Yama ptrace 1, SysRq off, unprivileged BPF off + JIT hardening, protected links/FIFOs/regular files, `suid_dumpable=0`, no redirects or source routing, reverse-path filter, martian logging, SYN cookies, IP forwarding off | `kernel_sysctl` |
| Live values | On real hosts each key is also set in the running kernel, and drift (a manual `sysctl -w`) is corrected on the next run | `kernel_sysctl` |
| Modules | `/etc/modprobe.d/60-hardening-blacklist.conf`: `install <mod> /bin/false` + `blacklist` for cramfs, freevxfs, jffs2, hfs, hfsplus, dccp, sctp, rds, tipc (usb-storage optional) | `kernel_modules` |
| Core dumps | `* hard core 0` in limits.d and `Storage=none` for systemd-coredump | `kernel_coredumps` |

Modules that are already loaded stay loaded until reboot: unloading them on a running system could break it.

## Key variables

| Variable | Default | Meaning |
|---|---|---|
| `kernel_sysctl_settings` | see defaults | The baseline keys |
| `kernel_sysctl_overrides` | `{}` | Merged over the baseline |
| `kernel_ip_forwarding` | `false` | Set `true` on routers and container hosts (Docker, Kubernetes) |
| `kernel_disable_usb_storage` | `false` | Block USB mass storage |
| `kernel_blacklist_extra` | `[]` | More modules to block |
| `kernel_disable_coredumps` | `true` | Disable core dumps |

Full list and types: [`meta/argument_specs.yml`](meta/argument_specs.yml).

## In containers

A container shares the host's kernel and has `/proc/sys` read-only, so with `hardening_in_container: true` only the files are written. This matters for safety too: in a privileged container, setting `kernel.*` keys would change the host.
