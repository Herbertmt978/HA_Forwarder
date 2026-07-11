# Todo Checkpoint

## Current todo

Task 2: implement bridge networking and retire the old listener owner.

## Active slice

Edit App metadata, runtime, AppArmor, and translations only; make the approved
RED contracts green without changing target behavior.

## Completed todos

- User approved rating-6 bridge design.
- Live Supervisor formula and migration semantics verified.
- Spec, baseline, and implementation plan written and committed.
- Isolated worktree created on `Herb/improve-security-rating`.
- Baseline metadata test, yamllint, actionlint, and diff checks passed.
- Task 1 committed in `9ec4376` after both RED cases were observed.
- Task 1 spec review passed.
- Task 1 quality review found and then cleared YAML boolean normalization.

## Evidence references

- Main validation run `29145458928` passed at v0.2.1.
- Live v0.2.1 had rating 5, two clients, two target sessions, and zero restarts.
- Supervisor source confirms base 5, AppArmor +1, host network -1.
- Config RED: host networking enabled and the required port mapping absent.
- Runtime RED: legacy `listen_port: 1234` prevented the expected fixed-5279 log.

## Blockers

None.

## Resume state

Open this checkpoint, then the plan. Continue with Task 2 production changes;
do not edit operator documentation until the implementation tests are green.

## Drift check

- Scope: aligned.
- Compatibility: host port and route remain pinned to 5279.
- New owners or adapters: none; tests now pin Supervisor as host-port owner.
- Retirement: `host_network`, `listen_port`, and bind capability remain explicit.
- Decision: continue.
