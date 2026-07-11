# Evidence Bundle Draft

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
- Rating 6 is described as a metadata calculation pending live deployment,
  while the plaintext, unauthenticated trusted-LAN boundary remains explicit.
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

## Final review fixes pending re-review

- Final branch review found that removing host networking changes loopback
  and local-only destination semantics: before 0.3.0, values including
  `localhost`, `localhost.`, `localhost.localdomain`, `127.0.0.0/8`,
  `0.0.0.0`, and `::1` or `[::1]` referred to the Home Assistant host or its
  local network stack; in 0.3.0 they refer to the App container.
- README, App documentation, and the changelog now require affected users to
  replace loopback destinations with a hostname or IP reachable from the App
  container before upgrading. Compatibility language is limited to
  non-loopback destinations.
- The current `192.168.50.89:5279` destination is a separate non-loopback LAN
  host and is therefore unaffected by this semantic change.
- The metadata security guard now normalizes all requested case-insensitive
  YAML boolean aliases so `yes`, `on`, or `1` cannot bypass checks that reject
  host networking and high-risk access, and `no`, `off`, or `0` cannot bypass
  the AppArmor requirement.
- `tests/test_config.sh` and `tests/test_run.sh` passed after the fixes, as did
  Bash syntax checks, yamllint, actionlint, and `git diff --check`. Final branch
  re-review remains pending.

No pull-request CI, release, or live HAOS evidence exists for 0.3.0 yet.
