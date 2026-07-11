# Todo Checkpoint

## Current todo

Task 1: add failing network-isolation and fixed-listener contracts.

## Active slice

Edit tests only, run them against v0.2.1, and capture the expected RED evidence.

## Completed todos

- User approved rating-6 bridge design.
- Live Supervisor formula and migration semantics verified.
- Spec, baseline, and implementation plan written and committed.
- Isolated worktree created on `Herb/improve-security-rating`.
- Baseline metadata test, yamllint, actionlint, and diff checks passed.

## Evidence references

- Main validation run `29145458928` passed at v0.2.1.
- Live v0.2.1 had rating 5, two clients, two target sessions, and zero restarts.
- Supervisor source confirms base 5, AppArmor +1, host network -1.

## Blockers

None.

## Resume state

Open this checkpoint, then the plan. Continue with Task 1 tests before touching
production metadata or runtime code.

## Drift check

- Scope: aligned.
- Compatibility: host port and route remain pinned to 5279.
- New owners or adapters: none.
- Retirement: `host_network`, `listen_port`, and bind capability remain explicit.
- Decision: continue.
