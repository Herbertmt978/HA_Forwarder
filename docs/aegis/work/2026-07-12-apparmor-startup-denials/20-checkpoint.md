# AppArmor Startup-Denial Cleanup Checkpoint

Date: 2026-07-12

## TodoCheckpointDraft

- Completed: confirmed the trailing-slash directory-match root cause against
  AppArmor, Home Assistant, S6, and the pinned base image.
- Completed: observed a regression test fail for exactly the two missing rules,
  then pass after adding only exact read-only directory access.
- Completed: hardened the policy test against missing, duplicate, reordered,
  quoted, broader exact-path, and unintended fix-attrs descendant rules.
- Completed: local App lint, YAML, Actions, ShellCheck, runtime tests, AppArmor
  compilation, and amd64 container build.
- Completed: two independent local reviews and the configured GitHub Codex
  review; final review had no findings.
- Completed: pull request 8, exact-main CI, annotated v0.3.2 tag, and public
  latest release.
- Completed: verified partial rollback backup `26501078`, in-place HAOS update,
  two denial-free starts, preserved security/runtime settings, and two
  end-to-end relay connections.
- Pending: none.
- Blocked on: nothing.

## ResumeStateHint

Live App `24118d52_ha_forwarder` is TCP Relay 0.3.2, started at rating 6 with
the custom enforcing profile, bridge networking, host port 5279, target
`192.168.50.89:5279`, zero container restarts, and no update available. Backup
`26501078` contains version 0.3.1. If a regression appears, stop 0.3.2, restore
that App from the backup, and reverify the route before resuming investigation.

## DriftCheckDraft

- Original intent: satisfied without expansion.
- Compatibility boundary: unchanged and verified before each live start.
- New owner, fallback, or adapter: none.
- Historical evidence: retained as the truthful 0.3.0/0.3.1 record.
- Retirement: the two known startup denials retire with 0.3.2; the 0.3.1
  release and backup remain rollback evidence.
- Decision: close as complete and retain the rollback backup.
