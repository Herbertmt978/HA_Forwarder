# AppArmor Startup-Denial Cleanup Evidence

Date: 2026-07-12

## Root-cause evidence

- Version 0.3.1 produced exactly two startup audit records for profile
  `24118d52_ha_forwarder`: S6 command `s6-ls` requested read access to
  `/etc/fix-attrs.d/` and `/etc/services.d/`.
- AppArmor matches a directory object only when a policy rule matches its
  trailing slash. `/etc/services.d/** rwix,` covered descendants but not the
  `/etc/services.d/` directory itself; no `/etc/fix-attrs.d/` rule existed.
- The pinned Home Assistant base image contains both directories, and its S6
  3.2.2.0 startup scripts list them even when they are empty.
- The observed request mask was only `r`. No evidence justified write,
  execution, capability, API, host-network, or fix-attrs descendant access.

## Implemented policy

- `ha_forwarder/apparmor.txt` adds only `/etc/fix-attrs.d/ r,` and
  `/etc/services.d/ r,`.
- `/etc/fix-attrs.d/**` remains absent. The existing service-file rule remains
  unchanged.
- `tests/test_config.sh` requires exactly one canonical read-only rule and one
  occurrence of each directory path. It rejects duplicate or alternate-form
  exact-path grants and forbids a fix-attrs descendant rule.
- The test was observed failing for both missing rules before the policy edit
  and passing afterwards.

## Repository validation and release

- Local validation passed: yamllint, actionlint, Home Assistant App linter
  2.21.0, ShellCheck, branding/config/runtime tests, `apparmor_parser`, and an
  amd64 build against the pinned Home Assistant base image.
- Two independent read-only reviews confirmed the least-privilege rule shape.
  A parser-coverage warning was fixed, and the final review reported no
  finding.
- Pull request 8 validated in run `29173312985`; both jobs passed. The GitHub
  Codex review found no major issue on the reviewed commit.
- Pull request 8 squash-merged as
  `e90fb26dfe8032efebdc50cf05faac0bb444db51`. Exact-main Validate run
  `29173432681` passed both jobs.
- Annotated tag `v0.3.2` peels to that exact main commit. The published latest
  release is https://github.com/Herbertmt978/HA_Forwarder/releases/tag/v0.3.2.

## Pre-update HAOS baseline

- Environment: Home Assistant OS 18.1, Home Assistant 2026.7.2, Supervisor
  2026.06.2, supported amd64 VM 100.
- Installed TCP Relay 0.3.1 was started at rating 6 with custom AppArmor,
  `host_network: false`, bridge address `172.30.33.3`, boot auto, watchdog true,
  auto-update true, host mapping 5279/tcp to 5279, and target
  `192.168.50.89:5279` with limits 64 and 15 seconds.
- The 0.3.1 container used the expected `socat` arguments and had zero restarts.
  No active established relay session existed before maintenance.
- The journal contained only the two known S6 directory-read denial shapes for
  the 0.3.1 start.
- Partial backup `26501078`, named `TCP Relay pre-0.3.2`, was created and
  verified to contain App `24118d52_ha_forwarder` version 0.3.1.

## Live 0.3.2 verification

- The App Store reload offered 0.3.2. The App was stopped, updated in place,
  and remained stopped while its version and persisted state were inspected.
- Before the first start, Supervisor reported version/latest 0.3.2, no update
  available, rating 6, custom AppArmor, no host networking, and unchanged
  options, host mapping, boot, watchdog, and auto-update settings.
- A journal cursor was captured immediately before each of two controlled
  starts. Both post-cursor windows contained zero denials for the TCP Relay
  profile and zero AppArmor denials overall.
- Each start completed the S6 fix-attrs and legacy-services phases, launched
  the unchanged `socat` relay, and listened on container IPv4 TCP 5279.
- After each start, Docker reported image 0.3.2, bridge networking, the custom
  profile `24118d52_ha_forwarder`, host mappings on 0.0.0.0 and :: TCP 5279,
  running state, and zero restarts.
- After each start, a controlled TCP connection from the Proxmox host through
  Home Assistant `192.168.50.29:5279` was accepted, forked, connected to
  `192.168.50.89:5279`, entered the transfer loop, and exited cleanly at EOF.
- Grott recorded both Home Assistant-source connections and disconnections.
  Its container remained running with zero restarts.
- The final denial scan remained zero after relay traffic. Only the 0.3.2 App
  image remains installed; version 0.3.1 remains available through release
  history and backup `26501078`.

## Residual risk and rollback

- TCP Relay remains plaintext and unauthenticated and must stay on a trusted
  LAN.
- Retain backup `26501078` until normal operation has provided sufficient
  confidence. Rollback is limited to App `24118d52_ha_forwarder`; after restore,
  verify rating, mapping, options, listener, and destination connectivity.
