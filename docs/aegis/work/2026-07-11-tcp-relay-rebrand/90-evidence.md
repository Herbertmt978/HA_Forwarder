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
- At the implementation-commit boundary, remote Actions, GitHub review,
  tag/release state, and live Supervisor rollout were still pending. Their
  subsequently observed evidence follows.

## Pull request and release evidence

- Pull request 6 merged after both Validate jobs passed and the GitHub Codex
  review reported no major issue on the reviewed commit.
- Exact-main Validate run 29171114678 passed on merge commit
  daaed914756629c81519244a76d52e2132eeabf0.
- Annotated tag v0.3.1 peels to the same merge commit.
- Public release:
  https://github.com/Herbertmt978/HA_Forwarder/releases/tag/v0.3.1
- The repository description is the approved tagline. Verified topics are
  home-assistant, home-assistant-addon, home-assistant-app, home-automation,
  socat, tcp-forwarding, tcp-proxy, and tcp-relay.

## Live Home Assistant rollout

- Environment: Home Assistant OS 18.1, Home Assistant 2026.7.2, Supervisor
  2026.06.2, amd64 HAOS VM 100.
- Before maintenance, live 0.3.0 was started at rating 6 on bridge networking
  with auto-update true, boot auto, watchdog true, host mapping 5279/tcp to
  5279, and target 192.168.50.89:5279.
- The two previously observed long-lived clients were already offline before
  maintenance. No active device session was interrupted by the update.
- Partial backup e30e25d3 was created and verified to contain installed App
  24118d52_ha_forwarder version 0.3.0.
- Store reload offered 0.3.1 on the existing slug. The App was stopped manually,
  updated in place, and remained stopped until its post-update state was
  inspected.
- Before start, Supervisor reported name TCP Relay, version/latest 0.3.1,
  rating 6, custom AppArmor, host_network false, the same four options, and the
  same Network mapping.
- After start, container addon_24118d52_ha_forwarder used the 0.3.1 image,
  bridge network mode, and remained running with zero restarts. Docker reported
  host mappings 0.0.0.0:5279 and [::]:5279; the App runtime remains the
  documented IPv4 listener.
- The live process remained:
  socat -d -d TCP-LISTEN:5279,fork,reuseaddr,max-children=64
  TCP:192.168.50.89:5279,connect-timeout=15.
- Direct destination connectivity from the App container succeeded. Grott was
  running with zero restarts, listening on IPv4/IPv6 TCP 5279, and reported no
  recent error, exception, fatal, or traceback lines.
- After the observation window, TCP Relay remained started at rating 6 with
  zero restarts and no relay error. No device was online, so a controlled TCP
  connection to Home Assistant host port 5279 verified the complete path:
  listener acceptance, child fork, connection to 192.168.50.89:5279, transfer
  loop start, clean EOF, and child exit status 0.
- Only the 0.3.1 App container and image remain installed. Version 0.3.0 is
  retained only in rollback backup e30e25d3; the earlier 0.2.1 rollback backup
  30cd2c41 remains available.

## AppArmor observation

- Version 0.3.1 startup produced two denials for S6 directory reads at
  /etc/fix-attrs.d/ and /etc/services.d/.
- The exact same two denial shapes were present at the earlier 0.3.0 start.
  They did not prevent S6 startup, the listener, destination connections, or
  the controlled end-to-end relay.
- No additional denial appeared during observation. This is documented as
  pre-existing, non-blocking startup denials and not attributed to the 0.3.1
  rebrand.
