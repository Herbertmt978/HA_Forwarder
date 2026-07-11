# Network Isolation Implementation Plan

## Goal

Ship HA Forwarder 0.3.0 with Supervisor port mapping and a live Home Assistant
security rating of 6 while preserving the current TCP route and clients.

## Architecture

Supervisor owns the host-to-container port mapping. The container owns one
fixed internal TCP listener on 5279. `run.sh` owns target validation and `socat`
arguments. AppArmor grants only the runtime access observed on HAOS.

## Tech stack

Home Assistant Supervisor 2026.06.2, YAML App metadata, POSIX shell, `jq`,
`socat`, Docker bridge networking, AppArmor, Bash regression tests, GitHub
Actions, GitHub releases, and HAOS QEMU guest-agent deployment.

## Baseline and authority references

- `docs/aegis/baseline/2026-07-11-initial-baseline.md`
- `docs/aegis/specs/2026-07-11-network-isolation-brief.md`
- Live Supervisor `rating_security` and Apps options endpoint source.
- `ha_forwarder/config.yaml`, `run.sh`, `apparmor.txt`, and current tests.

## Compatibility boundary

Keep host TCP 5279, target `192.168.50.89:5279`, two existing clients,
bidirectional byte transparency, target options, limits, timeout, boot auto,
watchdog, and auto-update. Move only host-port selection from Options to the
Network section. Do not grant any new API or namespace access.

## Verification

CI must pass metadata lint, yamllint, ShellCheck, runtime/config tests, AppArmor
compilation, and amd64 build. HAOS must show rating 6, bridge networking,
published port 5279, established client/target sessions, and no relevant errors.

## Task 1: Add failing network-isolation contracts

Files: `tests/test_config.sh`, `tests/test_run.sh`

Why: prove the security and fixed-listener behavior before changing production
metadata or runtime code.

Impact and compatibility: tests encode the approved Network-section migration
and ensure stale `listen_port` data cannot change the internal listener.

Verification: `bash tests/test_config.sh` and `bash tests/test_run.sh` must fail
for the expected host-network/listener assertions on v0.2.1.

- [ ] Add config assertions rejecting `host_network: true`, requiring
      `5279/tcp: 5279`, and rejecting dangerous access flags.
- [ ] Change the configured runtime case to pass legacy `listen_port: 1234` but
      expect `TCP-LISTEN:5279` and a log naming 5279.
- [ ] Run `bash tests/test_config.sh` and confirm it fails because host
      networking is still enabled.
- [ ] Run the runtime test in a temporary Home Assistant base container on
      HAOS and confirm it fails because v0.2.1 still listens on 1234.
- [ ] Commit the red contracts as `Test bridge-network listener behavior`.

## Task 2: Implement bridge networking and retire the old listener owner

Files: `ha_forwarder/config.yaml`, `ha_forwarder/run.sh`,
`ha_forwarder/apparmor.txt`, `ha_forwarder/translations/en.yaml`

Why: remove the host network namespace from the container and raise the rating
without adding unrelated privileges.

Impact and compatibility: Supervisor becomes the only host-port owner; the
container listener is fixed at 5279. Existing default-port users keep 5279.

Repair Track: remove the `host_network` rating penalty and expose only the
required TCP port. Verify the exact Supervisor rating inputs and live score.

Retirement Track: delete `listen_port` parsing, range validation, schema, and
translation. Do not retain a compatibility branch; unknown saved options are
ignored by Supervisor and the deployment explicitly persists sanitized options.

- [ ] Set version `0.3.0`, add `breaking_versions: ["0.3.0"]`, delete
      `host_network`, and add `ports`/`ports_description` for `5279/tcp`.
- [ ] Set `LISTEN_PORT=5279` in `run.sh`; remove its `jq` read and range check;
      keep all destination and resource protections unchanged.
- [ ] Remove `capability net_bind_service` from AppArmor because 5279 is not a
      privileged container port.
- [ ] Remove the `listen_port` translation and run both tests; confirm green.
- [ ] Commit the implementation as `Isolate the forwarder network`.

## Task 3: Align documentation and release metadata

Files: `README.md`, `ha_forwarder/DOCS.md`, `ha_forwarder/CHANGELOG.md`,
`.github/ISSUE_TEMPLATE/bug.yml`, the baseline and spec records.

Why: prevent operators from configuring a retired option and make the breaking
upgrade visible before installation.

Impact and compatibility: examples omit `listen_port`; instructions preserve
5279 in Network and explain custom-port migration.

- [ ] Replace host-network claims with bridge isolation and Network-section
      instructions in both operator documents.
- [ ] Add a 0.3.0 changelog entry covering rating 6, port migration, and the
      removed capability; update the issue placeholder.
- [ ] Update the baseline to make Supervisor port mapping the current contract.
- [ ] Run `yamllint .`, `actionlint .github/workflows/validate.yml`, both shell
      tests, and `git diff --check`; record any unavailable local scanner.
- [ ] Commit as `Document the isolated network upgrade`.

## Task 4: Review, merge, and release 0.3.0

Files: Git branch, pull request, tag, and GitHub release metadata.

Why: preserve review controls and publish a version matching App metadata.

Impact and compatibility: mark 0.3.0 as breaking and require exact-SHA green CI
before tagging.

- [ ] Push `Herb/improve-security-rating` and open a ready PR against `main`.
- [ ] Review the full diff, automated feedback, and both required CI jobs.
- [ ] Squash-merge only when the PR is clean and checks pass.
- [ ] Verify the merge SHA passes the main workflow, then create annotated tag
      `v0.3.0` and a non-draft release explaining the Network migration.
- [ ] Verify `main`, `origin/main`, tag target, latest release, and clean local
      state all agree.

## Task 5: Migrate HAOS with rollback and prove the rating

Files: live app `24118d52_ha_forwarder`, Supervisor persisted options/network,
and a new partial backup.

Why: demonstrate that the improved badge reflects real namespace reduction and
does not break production forwarding.

Impact and compatibility: a brief TCP reconnect occurs. No destination or Home
Assistant Core configuration changes.

- [ ] Create and verify a partial v0.2.1 backup; set app boot manual and stop it.
- [ ] Reload the Store, update to 0.3.0, and POST boot auto, watchdog true,
      sanitized target/limit/timeout options, and network `5279/tcp: 5279`.
- [ ] Start with an automatic failure path that stops 0.3.0 and restores only
      the app from the new backup.
- [ ] Verify rating 6, non-host Docker networking, published 5279, both clients,
      both target sessions, Grott post-cutover logs, and no AppArmor denials.
- [ ] Confirm the app remains stable with zero restarts and retain the backup as
      the bounded rollback artifact.

## Risks

- Port ownership moves between configuration surfaces; explicit persisted
  network verification prevents accidental loss of 5279.
- Update schema validation ignores stale options but does not necessarily erase
  persisted data; the deployment POST provides a clean replacement options map.
- Bridge NAT may change container/source addresses internally, but the old
  bridge-based v0.1.1 app and current destination behavior demonstrate this
  route is supported.
- AppArmor may need an audit-driven rule adjustment after namespace change;
  any denial blocks completion and triggers rollback rather than broad access.

## Retirement

`host_network`, configurable internal `listen_port`, and
`capability net_bind_service` are deleted. The v0.2.1 backup is retained only
for rollback; it can be deleted after a later operator-approved soak period.

## Self-review

- Every approved requirement maps to a task and live acceptance check.
- No placeholder or deferred implementation remains.
- Supervisor owns host ports; `run.sh` owns the fixed internal listener.
- The only deliberate compatibility change is the UI location of host-port
  selection, with 5279 preserved automatically.
- Repair and retirement tracks are explicit, and rating 7 permission-gaming is
  excluded.
