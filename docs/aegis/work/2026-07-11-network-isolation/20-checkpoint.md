# Todo Checkpoint

## Current todo

Complete. No in-scope implementation or rollout todo remains.

## Active slice

The version 0.3.0 release and HAOS rollout are verified. Retain the rollback
backup and monitor through normal Home Assistant operation.

## Completed todos

- User approved rating-6 bridge design.
- Live Supervisor formula and migration semantics verified.
- Spec, baseline, and implementation plan written and committed.
- Isolated worktree created on `Herb/improve-security-rating`.
- Baseline metadata test, yamllint, actionlint, and diff checks passed.
- Task 1 committed in `9ec4376` after both RED cases were observed.
- Task 1 spec review passed.
- Task 1 quality review found and then cleared YAML boolean normalization.
- Task 2 committed in `9c89a74`; both config and runtime tests are GREEN.
- Task 2 spec and code-quality/security reviews passed with no open issue.
- Task 3 documentation and metadata changes are complete.
- Task 3 spec review passed.
- Task 3 quality review found an unsafe custom-port instruction order and
  imprecise network-boundary language; iterative fixes cleared the final
  quality re-review with no Critical or Important issue.
- A checksum-verified jq 1.7.1 binary was used for a fresh local run of both
  configuration and runtime tests; both passed.
- Final branch review identified two release-blocking gaps: the documentation
  did not disclose the bridge-network loopback/local-only semantic change, and
  the metadata security guard recognized only the literal YAML booleans
  `true` and `false`.
- The public upgrade guidance now requires pre-0.3.0 loopback or local-only
  destinations to use a hostname or IP reachable from the App container, and
  the regression guard normalizes YAML aliases (`true`/`yes`/`on`/`1` and
  `false`/`no`/`off`/`0`) case-insensitively.
- Focused spec and quality re-reviews passed with no Critical or Important
  issue. Public compatibility language was narrowed further so unusual
  non-loopback networking is not guaranteed.
- Pull request 3 passed both GitHub validation jobs and the configured Codex
  review, then squash-merged to `main`.
- Exact-merge validation run `29150529095` passed on commit `ae6650b`.
- Annotated tag and GitHub release `v0.3.0` point to the verified merge commit.
- Partial rollback backup `30cd2c41` contains HA Forwarder version 0.2.1.
- Live version 0.3.0 reports rating 6, bridge networking, the expected
  `5279/tcp: 5279` mapping, sanitized options, auto boot, and watchdog enabled.
- Both clients and both destination sessions remained established with zero
  container restarts; Grott published both device state topics in consecutive
  cycles with no App error or AppArmor denial.

## Evidence references

- Main validation run `29145458928` passed at v0.2.1.
- Live v0.2.1 had rating 5, two clients, two target sessions, and zero restarts.
- Supervisor source confirms base 5, AppArmor +1, host network -1.
- Config RED: host networking enabled and the required port mapping absent.
- Runtime RED: legacy `listen_port: 1234` prevented the expected fixed-5279 log.
- GREEN: fixed listener 5279 ignores stale `listen_port`; metadata uses mapped
  `5279/tcp`; AppArmor no longer grants `net_bind_service`.
- Task 3 documents the two upgrade paths explicitly: custom-port users record
  the old value before updating; default-port users update directly and verify
  the `5279/tcp` mapping remains 5279.
- Final-fix config and runtime tests, Bash syntax, yamllint, actionlint, and
  `git diff --check` all pass; both focused re-reviews passed.
- yamllint, actionlint, and `git diff --check` pass on the completed branch.
- PR validation run `29150364699` and exact-merge validation run `29150529095`
  both passed the App linter, ShellCheck, tests, AppArmor compile, and container
  build.
- Live Supervisor remained healthy and supported on version 2026.06.2.

## Blockers

None.

## Resume state

No active slice remains. If a regression appears, stop version 0.3.0, run
`ha backups restore 30cd2c41 --app 24118d52_ha_forwarder`, and verify the
version 0.2.1 route before resuming investigation.

## Drift check

- Scope: aligned.
- Compatibility: host port and route remain pinned to 5279.
- New owners or adapters: none; Supervisor is the single host-port owner.
- Retirement: runtime/config access and current operator guidance are retired;
  `listen_port` remains only in explicit migration/history contexts.
- Decision: close as complete; retain the rollback backup.
