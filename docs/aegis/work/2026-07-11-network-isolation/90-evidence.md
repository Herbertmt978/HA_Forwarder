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

No 0.3.0 runtime or deployment evidence exists yet. The task remains active.
