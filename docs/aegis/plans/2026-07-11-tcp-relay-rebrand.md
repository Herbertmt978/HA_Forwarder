# TCP Relay Rebrand and 0.3.1 Release Plan

## Goal

Publish a compatibility-safe 0.3.1 rebrand with the repository and README title
`TCP Relay for Home Assistant`, the Home Assistant App display name `TCP Relay`,
and the tagline `Forward device TCP connections through Home Assistant to
another host.` Improve the README adoption path, verify the public identity,
release the change, and update the existing Home Assistant installation without
changing its forwarding behaviour.

## Architecture

This is a presentation and release-metadata change. The existing POSIX shell
runtime, `socat` relay, Supervisor bridge network, fixed container listener,
published host-port mapping, and custom AppArmor profile remain the single
runtime implementation. A small shell regression test owns the public-name and
stable-identity contract.

## Tech Stack

- Home Assistant App YAML metadata and Supervisor lifecycle
- POSIX shell, `jq`, and `socat`
- Alpine-based Home Assistant container image
- Bash regression tests, ShellCheck, yamllint, AppArmor parser, Docker, and
  GitHub Actions
- Markdown operator and repository documentation

## Baseline/Authority Refs

- User-approved names and tagline in the 2026-07-11 task
- `docs/aegis/baseline/2026-07-11-initial-baseline.md`
- `docs/aegis/work/2026-07-11-network-isolation/90-evidence.md`
- Current `ha_forwarder/config.yaml`, `run.sh`, `apparmor.txt`, and tests
- Home Assistant App metadata rules enforced by `frenck/action-addon-linter`

## Compatibility Boundary

- Keep the repository URL `https://github.com/Herbertmt978/HA_Forwarder`.
- Keep the App directory and slug `ha_forwarder`, installed Supervisor slug
  `24118d52_ha_forwarder`, AppArmor profile name, container listener TCP 5279,
  default host mapping TCP 5279, options, defaults, schemas, architectures,
  network mode, permissions, startup behaviour, and runtime arguments.
- Existing `target_host`, `target_port`, `max_connections`, `connect_timeout`,
  and Network mapping must survive the update unchanged.
- Historical 0.3.0 engineering records retain the name used at the time. The
  current workspace overview and active public documentation adopt the new
  name.

## Verification

Run `bash tests/test_branding.sh`, `bash tests/test_config.sh`,
`bash tests/test_run.sh`, `yamllint .`, ShellCheck for every shell test and
runtime script, AppArmor compilation, the Home Assistant App linter, and an
amd64 container build. After merge, confirm GitHub Actions succeeds, create the
annotated `v0.3.1` release, update the installed App, and verify version, rating
6, bridge networking, options, port mapping, process health, TCP sessions, logs,
and destination delivery.

## Plan Basis

- Fact: version 0.3.0 is live and verified at Home Assistant security rating 6.
- Fact: the competing `garysleet/ha-tcp-relay-addon` currently uses host
  networking and has no tests, CI, AppArmor profile, release, or licence.
- Assumption: “Repository/README title” means the public repository metadata
  and documentation title, not a GitHub URL rename; this matches the approved
  requirement to preserve installed repository compatibility.
- Unknown: GitHub and Supervisor cache propagation time after the release. The
  rollout will explicitly reload the Store and inspect the installed version.
- Ripple Signal Triage: public display metadata, image labels, support forms,
  current documentation, tests, release notes, GitHub presentation, and the live
  App are in scope. Runtime owners and data-flow contracts do not expand.
- User-added scope: set a focused GitHub topic set for Home Assistant and TCP
  relay discovery without renaming the repository URL.

## Files

- Create `tests/test_branding.sh`.
- Modify `.github/workflows/validate.yml`.
- Modify `repository.yaml`, `ha_forwarder/config.yaml`, and
  `ha_forwarder/Dockerfile`.
- Modify `README.md`, `ha_forwarder/README.md`, `ha_forwarder/DOCS.md`,
  `ha_forwarder/CHANGELOG.md`, `.github/ISSUE_TEMPLATE/bug.yml`,
  `docs/aegis/README.md`, and `docs/aegis/INDEX.md`.
- Do not modify `ha_forwarder/run.sh`, `ha_forwarder/apparmor.txt`, option
  translations, directory names, or repository URLs.

## Tasks

### Task 1: Pin the public-name and upgrade-identity contract

Files: create `tests/test_branding.sh`; modify `.github/workflows/validate.yml`.

Why: a future cosmetic rename must not accidentally create a second App or
break upgrades by changing the slug or repository URL.

Impact/Compatibility: test-only; it asserts new display text and stable internal
identifiers without affecting the image or runtime.

Verification: `bash tests/test_branding.sh` must fail against 0.3.0 metadata,
then pass after the Task 3 README rewrite. `shellcheck tests/test_branding.sh`
must pass.

- [ ] Write `tests/test_branding.sh` with exact assertions for repository name,
  App name, version `0.3.1`, approved tagline, Docker image title, stable
  `ha_forwarder` slug, and stable GitHub URLs; add it to the workflow test and
  ShellCheck commands.
- [ ] Run `bash tests/test_branding.sh` and confirm it exits non-zero because the
  active metadata still says `HA Forwarder` and version `0.3.0`.
- [ ] Make no production change in this task; the minimal passing metadata is
  applied in Task 2.
- [ ] After Task 3, run `bash tests/test_branding.sh` and
  `shellcheck tests/test_branding.sh` and require both to exit zero.
- [ ] Commit the branding contract together with the metadata and README
  updates so the branch never records a deliberately failing test.

### Task 2: Apply the compatibility-safe 0.3.1 metadata rebrand

Files: modify `repository.yaml`, `ha_forwarder/config.yaml`,
`ha_forwarder/Dockerfile`, `ha_forwarder/CHANGELOG.md`, and
`.github/ISSUE_TEMPLATE/bug.yml`.

Why: Home Assistant and GitHub should show the approved name consistently.

Impact/Compatibility: only public names, descriptions, image labels, support
copy, and version change. The slug, path, network and options contracts remain
byte-for-byte unchanged.

Verification: `git diff --word-diff`, `bash tests/test_branding.sh`,
`bash tests/test_config.sh`, and `yamllint .`. Before Task 3, the branding
test must report only the four expected README title/tagline mismatches.

- [ ] Use the failing branding assertions from Task 1 as the metadata test.
- [ ] Confirm the failure names the old App title or 0.3.0 version.
- [ ] Set repository name to `TCP Relay for Home Assistant`, App name to
  `TCP Relay`, version to `0.3.1`, description/tagline to the approved sentence,
  listener description to `TCP Relay listener`, OCI title to
  `Home Assistant App: TCP Relay`, and support-form wording to `TCP Relay`.
- [ ] Run `bash tests/test_branding.sh` and confirm only the four README
  mismatches remain; run `bash tests/test_config.sh` and `yamllint .` with
  zero exits; inspect that `git diff` shows no slug, option, port, network,
  permission, or URL change.
- [ ] Keep the metadata with the uncommitted branding contract until Task 3
  makes the complete contract green, then commit the cohesive rebrand.

### Task 3: Rewrite the active documentation for adoption and trust

Files: modify `README.md`, `ha_forwarder/README.md`,
`ha_forwarder/DOCS.md`, and `docs/aegis/README.md`.

Why: users should immediately understand the device-to-destination use case,
install safely, see the traffic path, and find complete operating guidance.

Impact/Compatibility: documentation only. Historical specifications, plans, and
rollout evidence retain their original terminology.

Verification: inspect rendered Markdown structure, run the branding test and a
link/reference scan, then run a quick README council for clarity,
non-repetition, trust placement, and skimmer/deep-reader usefulness.

- [ ] Extend the branding assertions to cover the exact README title and
  approved tagline before rewriting the documents.
- [ ] Run `bash tests/test_branding.sh` and confirm the old README title is
  reported.
- [ ] Rewrite the root README problem-first with the existing six evidence
  badges, one install button, navigation links, a concise traffic-flow example,
  a trust block near installation, quick configuration, collapsed operational
  detail, security/migration guidance, development checks, support, and licence;
  align the App README, operating guide, and active Aegis overview.
- [ ] Run `bash tests/test_branding.sh`; scan with
  `rg -n 'HA Forwarder' README.md ha_forwarder/README.md ha_forwarder/DOCS.md docs/aegis/README.md .github/ISSUE_TEMPLATE/bug.yml`; then council-validate
  `README.md` and apply material findings.
- [ ] Commit the documentation polish after the README council passes.

### Task 4: Validate, review, merge, and publish 0.3.1

Files: branch, pull request, tag, GitHub release, and GitHub repository metadata.

Why: the public change needs reproducible checks and an auditable release.

Impact/Compatibility: public repository state only; no force-push or history
rewrite. Main-branch protections and review controls remain in force.

Verification: clean working tree, reviewed staged diff, local validation suite,
green GitHub Actions, no unresolved review threads, and release/tag pointing to
the merged commit.

- [ ] Treat the local regression suite as the release test and add no bypasses.
- [ ] Run the complete local suite and confirm every check exits zero before
  staging.
- [ ] Make the smallest fixes required by review, rerun affected checks, stage
  only planned files, inspect `git diff --cached`, commit, and push
  `Herb/rebrand-tcp-relay`.
- [ ] Open a ready pull request, wait for green checks and review, merge it, then
  verify local `main` matches `origin/main`.
- [ ] Create annotated tag `v0.3.1`, publish a GitHub release from the changelog,
  and verify both resolve to the merged commit; update the repository description
  to the approved tagline and verify the focused Home Assistant/TCP topic set
  without renaming its URL.

### Task 5: Update and prove the live Home Assistant App

Files: Home Assistant Supervisor state for installed App
`24118d52_ha_forwarder`; a new partial rollback backup; rollout evidence record.

Why: the user asked for the local VM installation to receive the released name
while continuing its current production relay.

Impact/Compatibility: controlled App rebuild/restart. Existing options and
Network mapping are captured before the update and restored exactly if needed.

Verification: version `0.3.1`, display name `TCP Relay`, rating 6, custom
AppArmor, bridge networking, zero unexpected restarts, expected `socat`
arguments, established client sessions, clean App/AppArmor logs, and successful
destination delivery.

- [ ] Capture current App info, options, Network mapping, logs, sessions, and
  destination health; create a partial Home Assistant backup of the installed
  0.3.0 App and record its backup identifier.
- [ ] Reload the App Store and confirm Supervisor offers 0.3.1 before changing
  the running App.
- [ ] Disable automatic restart controls only for the update window, update the
  existing slug in place, preserve the captured settings, and restart it.
- [ ] Verify every runtime and security invariant above, re-enable the prior
  watchdog/auto-update settings, and monitor for a stable observation window.
- [ ] If any invariant fails, stop 0.3.1 and restore the new partial backup; if
  all pass, append concrete evidence to the Aegis work record and retain the
  rollback backup until the user chooses to remove it.

## Risks

- Supervisor may cache repository metadata; explicit Store reload and version
  inspection prevent updating against stale content.
- A public-name sweep could accidentally touch internal identifiers; the new
  regression test and staged-diff inspection prevent this.
- README polish could overstate security; the trust block explicitly states
  plaintext, unauthenticated TCP and trusted-LAN scope.
- A release could be tagged before merge; tag and release verification require
  the merged main commit SHA.

## Retirement

The old `HA Forwarder` public name retires from active repository metadata,
current support copy, and current operator documentation in 0.3.1. It remains
in historical 0.3.0 records and rollback evidence so those records remain
truthful. No runtime owner, fallback, compatibility adapter, or duplicated App
is introduced or retired.
