# HA Forwarder Initial Baseline

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
- Regression contracts: `tests/test_config.sh` and `tests/test_run.sh`.

## Contract inventory

- One fixed IPv4 listener on container TCP 5279 forwards byte streams
  bidirectionally to one configured hostname or IP and TCP port. Supervisor
  publishes it on host TCP 5279 by default; operators select another host port
  in the App's **Network** section.
- `target_host` is required; target port, connection limit, and connection
  timeout have bounded defaults.
- Existing production route on HAOS is host port 5279 to
  `192.168.50.89:5279` with two long-lived clients.
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
AppArmor +1, and host networking -1. Version 0.3.0 implements Supervisor port
mapping with a fixed container listener and removes the host-network penalty,
so its metadata calculates to the expected rating 6 without granting new
access. Live version 0.3.0 deployment evidence remains pending. Signing is
currently hardcoded unavailable; ingress/auth access is not legitimate for
this relay.

## Compatibility boundaries

External clients continue using the Home Assistant address and host port 5279
by default, while the container listener remains fixed at TCP 5279. Operators
who used a custom pre-0.3.0 `listen_port` must set that host port in the App's
**Network** section. Destination, limits, timeout, byte transparency, boot
behavior, watchdog, and auto-update behavior remain unchanged.
