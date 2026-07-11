# Todo Checkpoint

## Current todo

Task 3: align operator documentation, changelog, and architecture baseline.

## Active slice

Remove retired `listen_port` and host-network guidance, document the Network
section and breaking upgrade, and align the baseline with the implementation.

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

## Evidence references

- Main validation run `29145458928` passed at v0.2.1.
- Live v0.2.1 had rating 5, two clients, two target sessions, and zero restarts.
- Supervisor source confirms base 5, AppArmor +1, host network -1.
- Config RED: host networking enabled and the required port mapping absent.
- Runtime RED: legacy `listen_port: 1234` prevented the expected fixed-5279 log.
- GREEN: fixed listener 5279 ignores stale `listen_port`; metadata uses mapped
  `5279/tcp`; AppArmor no longer grants `net_bind_service`.

## Blockers

None.

## Resume state

Open this checkpoint, then the plan. Continue with Task 3 documentation and
baseline changes only; do not publish or deploy until their reviews pass.

## Drift check

- Scope: aligned.
- Compatibility: host port and route remain pinned to 5279.
- New owners or adapters: none; Supervisor is the single host-port owner.
- Retirement: runtime/config access is deleted; operator references remain to
  be retired in Task 3.
- Decision: continue.
