# TCP Relay for Home Assistant Baseline

Date: 2026-07-11

## Project structure

- `ha_forwarder/`: Home Assistant App metadata, container, runtime, AppArmor,
  translations, changelog, and operator documentation.
- `tests/`: shell-based metadata and runtime regression tests.
- `.github/workflows/validate.yml`: lint, tests, AppArmor compilation, and amd64
  container build.
- `README.md` and `repository.yaml`: repository installation and discovery.

## Technology stack

- POSIX shell runtime using `jq` and `socat`.
- Home Assistant App configuration and Supervisor lifecycle.
- Alpine-based Home Assistant container image.
- Docker networking and AppArmor confinement.

## Ownership mapping

- App capabilities and network exposure: `ha_forwarder/config.yaml`.
- Forwarding behavior and input validation: `ha_forwarder/run.sh`.
- Filesystem/process/network confinement: `ha_forwarder/apparmor.txt`.
- User-facing operation and migration: `README.md` and
  `ha_forwarder/DOCS.md`.
- Public identity and stable upgrade contract: `tests/test_branding.sh`.
- Runtime and security contracts: `tests/test_config.sh` and
  `tests/test_run.sh`.

## Contract inventory

- One fixed IPv4 listener on container TCP 5279 forwards byte streams
  bidirectionally to one configured hostname or IP and TCP port. Supervisor
  publishes it on host TCP 5279 by default; operators select another host port
  in the App's **Network** section.
- `target_host` is required; target port, connection limit, and connection
  timeout have bounded defaults.
- The production route on HAOS is host port 5279 to
  `192.168.50.89:5279`. Two long-lived clients were observed on version 0.3.0
  earlier on 2026-07-11; both were offline before the 0.3.1 update.
- UDP, inbound IPv6, TLS, authentication, source allowlists, and payload
  inspection are outside scope.

## Dependency direction

Supervisor supplies validated options and network mappings. `run.sh` consumes
options and launches `socat`; documentation and tests describe and verify that
contract. Runtime code must not infer Supervisor configuration outside the
documented options file and container network.

## Test system

- `tests/test_config.sh` verifies Supervisor compatibility invariants.
- `tests/test_run.sh` substitutes `socat` and checks exact arguments and errors.
- `tests/test_branding.sh` pins the public name while preserving the existing
  slug and repository URLs.
- CI runs yamllint, ShellCheck, AppArmor compilation, the tests, the Home
  Assistant App linter, and an amd64 image build.

## Build and deployment

GitHub pull requests validate changes. Releases are annotated `vX.Y.Z` tags.
The HAOS App Store tracks the GitHub repository and builds the selected version
locally before Supervisor starts it.

## Known anti-patterns

- Do not add Home Assistant/Supervisor/API access merely to improve the rating.
- Do not reintroduce blanket AppArmor filesystem execution.
- Do not accept raw `socat` address options from configuration.
- Do not make a mapped container port depend on an unrelated runtime option.

## Last review findings

Live Supervisor 2026.06.2 calculated version 0.2.1 at rating 5: base 5, custom
AppArmor +1, and host networking -1. Live version 0.3.1 reports rating 6 with
Supervisor port mapping, a fixed container listener, custom AppArmor, and no
host networking or new permissions. Its container remained at zero restarts,
and a controlled connection through the published Home Assistant port reached
the configured destination successfully.

Both the earlier 0.3.0 start and the 0.3.1 start produced the same two
non-blocking AppArmor denials while S6 listed /etc/fix-attrs.d/ and
/etc/services.d/. S6 and the relay continued normally, and no further denial
appeared during observation. Treat eliminating that pre-existing startup noise
as a future confinement-maintenance task, not a 0.3.1 regression. Signing is
currently hardcoded unavailable; ingress/auth access is not legitimate for
this relay.

## Compatibility boundaries

External clients continue using the Home Assistant address and host port 5279
by default, while the container listener remains fixed at TCP 5279. Operators
who used a custom pre-0.3.0 `listen_port` must set that host port in the App's
**Network** section. The direct LAN-IP production route, limits, timeout, byte
transparency, boot behavior, watchdog, and auto-update behavior remain
unchanged. Pre-0.3.0 loopback or other local-only destinations must instead be
replaced with an address reachable from the App container.

The public repository/README title is TCP Relay for Home Assistant and the App
display name is TCP Relay. The directory, installed slug, AppArmor profile,
repository URL, container image namespace, and development image tag retain
their existing ha_forwarder / HA_Forwarder compatibility identities.
