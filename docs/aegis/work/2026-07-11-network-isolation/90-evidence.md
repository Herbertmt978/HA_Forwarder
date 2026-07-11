# Evidence Bundle

## Planning evidence

- Approved spec and implementation plan are indexed in `docs/aegis/INDEX.md`.
- Live Supervisor 2026.06.2 source supplied the rating formula and options API
  sequencing constraint.
- Independent read-only reviews agreed that rating 6 is the honest ceiling and
  that bridge mapping is the minimal design.

## Baseline evidence

- `tests/test_config.sh`: passed before implementation.
- `yamllint .`: passed before implementation.
- `actionlint .github/workflows/validate.yml`: passed before implementation.
- `git diff --check`: passed before implementation.
- Runtime baseline is covered by green main CI run `29145458928`.

## Task 1 RED evidence

- `tests/test_config.sh` failed on v0.2.1 because `host_network` was enabled and
  `5279/tcp: 5279` was absent.
- `tests/test_run.sh` failed in an isolated v0.2.1 environment because the
  runtime consumed stale `listen_port: 1234` instead of fixed port 5279.
- Bash syntax and diff checks passed.
- Spec compliance review passed.
- Quality review required case-insensitive YAML boolean checks; commit
  `9ec4376` fixed them and the re-review passed.

## Task 2 GREEN evidence

- `tests/test_config.sh`: passed with bridge mapping and security inputs.
- `tests/test_run.sh`: passed with jq 1.7.1; stale `listen_port: 1234` could not
  change fixed listener 5279.
- POSIX/Bash syntax, yamllint, and diff checks passed.
- Spec compliance review passed.
- Code-quality/security review found no Critical or Important issue.
- Commit `9c89a74` changes only config, runtime, AppArmor, and translations.

## Task 3 documentation evidence

- Current documentation describes a Supervisor-managed internal bridge network
  in a network namespace separate from the host; it does not overstate that
  boundary as a private or isolated network.
- The version 0.3.0 breaking upgrade has distinct custom-port and default-port
  paths. Custom-port users record the legacy value before installing 0.3.0.
- Rating 6 was initially documented as a metadata calculation pending live
  deployment, while the plaintext, unauthenticated trusted-LAN boundary
  remained explicit.
- The issue form captures both redacted App options and the `5279/tcp` Network
  mapping, with `N/A` guidance for pre-0.3.0 reports.
- Spec review passed. Quality review findings were corrected in focused
  follow-up commits; the final re-review passed with no Critical or Important
  issue.

## Completed-branch local evidence

- `tests/test_config.sh`: passed.
- `tests/test_run.sh`: passed with checksum-verified jq 1.7.1.
- `yamllint .`: passed.
- `actionlint`: passed.
- `git diff --check main...HEAD`: passed.
- `ha_forwarder/run.sh` remains tracked executable (`100755`).
- Docker Desktop was unavailable locally, so the container build, ShellCheck,
  AppArmor compile, and Home Assistant App linter remain CI gates.
- The repository has no project-specific `scripts/security-gate.sh`; no such
  security-gate result is claimed.

## Final review fix and re-review evidence

- Final branch review found that removing host networking changes loopback
  and local-only destination semantics: before 0.3.0, values including
  `localhost`, `localhost.`, `localhost.localdomain`, `127.0.0.0/8`,
  `0.0.0.0`, and `::1` or `[::1]` referred to the Home Assistant host or its
  local network stack; in 0.3.0 they refer to the App container.
- README, App documentation, and the changelog now require affected users to
  replace loopback destinations with a hostname or IP reachable from the App
  container before upgrading. Compatibility language distinguishes direct
  separate-LAN routes without guaranteeing every unusual non-loopback case.
- The current `192.168.50.89:5279` destination is a separate non-loopback LAN
  host and is therefore unaffected by this semantic change.
- The metadata security guard now normalizes all requested case-insensitive
  YAML boolean aliases so `yes`, `on`, or `1` cannot bypass checks that reject
  host networking and high-risk access, and `no`, `off`, or `0` cannot bypass
  the AppArmor requirement.
- `tests/test_config.sh` and `tests/test_run.sh` passed after the fixes, as did
  Bash syntax checks, yamllint, actionlint, and `git diff --check`.
- Focused spec and quality re-reviews passed with no Critical or Important
  finding. The quality review noted that the lightweight trusted-metadata guard
  does not parse contrived YAML anchors or quoted keys. It is a repository
  regression check rather than a runtime security boundary; code review remains
  the backstop for those forms.

## Pull request and release evidence

- Pull request 3 merged after both `Validate` jobs passed in run `29150364699`.
- The configured Codex review reported no major issue on the reviewed branch.
- Exact-merge run `29150529095` passed on `main` commit `ae6650b`, including the
  Home Assistant App linter, ShellCheck, both tests, AppArmor compilation, and
  the amd64 container build.
- Annotated tag `v0.3.0` and the published latest GitHub release both resolve to
  commit `ae6650b`.

## Live HAOS evidence

- Partial backup `30cd2c41` was created before maintenance and verified to
  contain HA Forwarder version 0.2.1.
- Supervisor 2026.06.2 installed version 0.3.0 while the App was stopped with
  boot set to manual and watchdog disabled.
- Before start, the stale `listen_port` value was removed and the saved state
  was verified as target `192.168.50.89:5279`, `max_connections: 64`,
  `connect_timeout: 15`, and Network mapping `5279/tcp: 5279`.
- The running App reports rating 6, `host_network: false`, bridge address
  `172.30.33.3`, auto boot, auto-update, watchdog, and no update available.
- Docker published host TCP 5279 to container TCP 5279 on the version 0.3.0
  image and reported zero restarts throughout the stability window.
- Both source sessions (`192.168.51.47` and `192.168.50.39`) and both target
  sessions to `192.168.50.89:5279` remained established inside the container.
- Grott processed packets and published both Home Assistant state topics in
  consecutive 11:18, 11:19, and 11:20 UTC cycles after cutover.
- Supervisor remained healthy and supported. App logs contained no error,
  failure, denial, fatal, exception, or traceback, and the kernel journal
  contained no relevant AppArmor denial.

## Residual risk and rollback

- The TCP relay remains plaintext and unauthenticated and must stay on a
  trusted LAN.
- Custom host ports and pre-0.3.0 loopback/local-only destinations require the
  documented manual migration.
- The trusted-metadata AWK guard does not parse contrived YAML anchors or
  quoted keys; review remains the backstop.
- Backup `30cd2c41` is retained as the version 0.2.1 rollback point.
