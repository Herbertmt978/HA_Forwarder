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
- Runtime baseline is covered by green main CI run `29145458928`; local Git Bash
  lacks `jq`, so runtime RED/GREEN will run in a temporary HAOS container and CI.

## Runtime evidence status

## Task 1 RED evidence

- `tests/test_config.sh` failed on v0.2.1 because `host_network` was enabled and
  `5279/tcp: 5279` was absent.
- `tests/test_run.sh` failed in an isolated v0.2.1 environment because the
  runtime consumed stale `listen_port: 1234` instead of fixed port 5279.
- Bash syntax and diff checks passed.
- Spec compliance review passed.
- Quality review required case-insensitive YAML boolean checks; commit
  `9ec4376` fixed them and the re-review passed.

No 0.3.0 GREEN or deployment evidence exists yet. The task remains active.
