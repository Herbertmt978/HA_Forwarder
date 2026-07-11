# TCP Relay Rebrand Task Intent

Date: 2026-07-11

## Requested outcome

Release version 0.3.1 with the repository and README title **TCP Relay for Home
Assistant**, the Home Assistant App display name **TCP Relay**, and the tagline
**Forward device TCP connections through Home Assistant to another host.**
Make the README polished and trustworthy, compare the implementation fairly
with garysleet/ha-tcp-relay-addon, merge the reviewed change, publish the
release, and update the existing Home Assistant VM installation.

## Scope

- Public repository/App metadata, active documentation, issue form, image
  labels, changelog, branding regression test, CI, GitHub release presentation,
  and live App update.
- Evidence-based competitor comparison at commit
  a0685669f625d782a11ddad908bf7199983703a5.

## Non-goals

- No GitHub repository URL rename.
- No App directory, slug, AppArmor identity, runtime, protocol, port, option,
  network, permission, architecture, or startup change.
- No claim that either relay supplies TLS, authentication, client allowlisting,
  traffic inspection, or protocol conversion.
- No rewrite of historical 0.3.0 engineering evidence.

## Baseline read set

- docs/aegis/baseline/2026-07-11-initial-baseline.md
- docs/aegis/work/2026-07-11-network-isolation/90-evidence.md
- ha_forwarder/config.yaml, run.sh, apparmor.txt, Dockerfile
- tests/test_config.sh, tests/test_run.sh, .github/workflows/validate.yml
- Root and App README, operating guide, changelog, issue form, and repository
  metadata

## Impact statement

Supervisor must recognize 0.3.1 as an in-place update to installed slug
24118d52_ha_forwarder. The App will rebuild/restart once during rollout, so
current configuration, network mapping, safety controls, sessions, destination
health, and rollback state must be captured before updating and reverified
afterwards.

## Success evidence and stop conditions

Success requires the full local and GitHub validation suites, approved README
council and code review, merged main commit, matching v0.3.1 tag/release, and a
stable live App showing the new name, version 0.3.1, rating 6, bridge networking,
preserved settings, expected relay process/sessions, and clean logs.

Stop with blocked, needs-verification, or scope-exceeded if repository
compatibility, release authority, CI, VM access, rollback readiness, or live
forwarding cannot be proven. Do not broaden the runtime or repository URL to
work around a failure.
