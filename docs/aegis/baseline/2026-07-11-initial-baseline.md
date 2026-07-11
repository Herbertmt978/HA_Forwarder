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

- One IPv4 TCP listener forwards byte streams bidirectionally to one configured
  hostname or IP and TCP port.
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

Supervisor 2026.06.2 calculates rating 5 as base 5, custom AppArmor +1, and
host networking -1. Removing host networking yields rating 6 without granting
new access. Signing is currently hardcoded unavailable; ingress/auth access is
not legitimate for this relay.

## Compatibility boundaries

External clients must continue using the Home Assistant address and host port
5279. Destination, limits, timeout, byte transparency, boot behavior, watchdog,
and auto-update behavior remain unchanged. The listen-port control may move
from App options to Supervisor's Network section only if 5279 is preserved.
