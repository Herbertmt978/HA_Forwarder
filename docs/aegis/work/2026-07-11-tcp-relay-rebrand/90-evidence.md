# TCP Relay Rebrand Evidence

Date: 2026-07-11

## Initial state

- Feature branch: Herb/rebrand-tcp-relay
- Starting main commit: 028eb036a6ab6162b07b95d921dbcfee77d84575
- Runtime baseline command:

      docker run --rm --volume "<worktree>:/work" --workdir /work alpine:3.23
        sh -c "apk add --no-cache bash jq >/dev/null &&
        bash tests/test_config.sh && bash tests/test_run.sh"

- Result: All config compatibility tests passed. and
  All run.sh tests passed.
- Local Git Bash alone could not run the runtime test because jq is not
  installed; the container supplies the same Bash/jq prerequisites used by CI.

## Independent audits

- Rebrand audit confirmed all active display surfaces and that the repository
  URL, directory/slug, AppArmor identity, option/schema/port/network/runtime
  contracts, and historical records must remain unchanged.
- Competitor snapshot:
  [a0685669](https://github.com/garysleet/ha-tcp-relay-addon/commit/a0685669f625d782a11ddad908bf7199983703a5),
  committed 2026-07-11. It contains four files, enables host_network, and has
  no AppArmor profile, validation tests, CI workflow, README, operating docs,
  changelog, licence, tags, or releases. Its strength is a very small runtime
  and a directly configurable listener port.

## Task 1: branding and stable-identity contract

- Created tests/test_branding.sh and wired it into workflow ShellCheck and test
  execution.
- Initial run exited 1 with exactly eleven old public name, version,
  description, title, and tagline mismatches. Stable slug and URL assertions
  passed.
- Git Bash syntax check exited 0.
- Alpine 3.23 ShellCheck exited 0.
- Independent spec-compliance review: PASS, no findings.
- Independent code-quality review: PASS, no findings.
- Plan sequencing correction: because the same contract covers README text,
  Task 2 is expected to leave four README-only failures; Task 3 owns the first
  fully green branding run.

## GitHub discoverability

- Added and verified these public topics on
  https://github.com/Herbertmt978/HA_Forwarder:
  home-assistant, home-assistant-addon, home-assistant-app, home-automation,
  socat, tcp-forwarding, tcp-proxy, and tcp-relay.
- Repository URL remained unchanged.

## Task 2: version and public metadata

- repository.yaml now displays TCP Relay for Home Assistant.
- config.yaml now displays TCP Relay at version 0.3.1 with the approved
  tagline and listener label.
- OCI labels, the issue form, and the 0.3.1 changelog align with the approved
  public names.
- Branding test reduced from eleven failures to exactly four README-only
  title/tagline mismatches.
- Configuration test, scoped yamllint, and git diff --check passed.
- Spec review initially found ambiguous changelog wording. The implementer
  explicitly named both repository/README and App surfaces; re-review passed.
- Independent code-quality review: PASS, no findings.
- Invariant review found no URL, slug, path, AppArmor, breaking-version,
  architecture, startup, port, option, schema, network, runtime, base-image, or
  command change.

## Task 3: active documentation

- Root README now uses the approved title/tagline, preserves the six evidence
  badges and one install button, and follows problem, trust/install, traffic
  demonstration, configuration, behavior/limits, security, collapsed migration,
  development, and support/licence order.
- App Store README, full operating guide, and active Aegis overview use TCP
  Relay naming while preserving URLs, paths, and historical version facts.
- Branding, configuration, and runtime tests passed together in disposable
  Alpine with Bash and jq. Active-doc old-name scan, link/reference/local-target
  checks, and git diff --check passed.
- Quick README council: PASS at 0.96 confidence. It found no blocking clarity,
  trust, navigation, or technical-claim issue; the four-column option table is
  a minor narrow-screen watch item.
- Spec review found one cosmetic compatibility drift in the documented Docker
  development tag. The implementer restored ha-forwarder:dev; re-review passed.
- Independent documentation-quality review: PASS, no material findings.

## Completed-branch local validation

- git diff --check: passed.
- actionlint on .github/workflows/validate.yml: passed.
- yamllint on the full repository: passed in Ubuntu 24.04.
- ShellCheck on run.sh and all three test scripts: passed in Ubuntu 24.04.
- Branding, configuration, and runtime tests: passed in Ubuntu 24.04.
- AppArmor profile compilation with skip-kernel-load: exited 0. The disposable
  container reported its expected missing kernel cache interface after parsing;
  no profile error was reported.
- Pinned frenck/action-addon-linter v2.21.0 image built from commit
  f995494fd84fae6310d23617e66d0e37de4f14eb and linted ha_forwarder with exit 0.
- amd64 App image built from the pinned Home Assistant base with
  BUILD_VERSION=0.3.1-validation and exit 0.
- ha_forwarder/run.sh remains tracked executable at mode 100755.

## Final review and pre-commit gate

- Final whole-branch reviewer inspected tracked and untracked work against
  028eb036a6ab6162b07b95d921dbcfee77d84575 and returned advisory MERGE READY
  with no blocking or warning findings.
- After the review and interim reflection were recorded, the complete local
  matrix was run again: repository yamllint, full ShellCheck, all three tests,
  AppArmor compilation, pinned Home Assistant App linter, actionlint, amd64
  image build, diff check, secret-pattern scan, and active-name scan all exited
  0.
- Remote Actions, GitHub review, tag/release state, and live Supervisor rollout
  remain future evidence and are not claimed here.
