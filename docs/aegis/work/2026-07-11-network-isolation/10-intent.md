# Task Intent: Network Isolation

## Requested outcome

Raise HA Forwarder's live Home Assistant security rating from 5 to 6 without
changing what the production forwarder does for its two clients.

## Scope

- Replace host networking with Supervisor TCP port mapping.
- Fix the container listener at 5279 while preserving host port 5279.
- Retire the `listen_port` option and no-longer-needed bind capability.
- Test, document, review, release, deploy, and verify the migration.

## Success evidence

- Green CI and exact release metadata for 0.3.0.
- Live rating 6 and non-host Docker networking.
- Host 5279 mapped to container 5279.
- Both clients and both destination sessions established.
- Clean runtime/AppArmor logs and post-cutover Grott activity.

## Stop conditions

- Done: every acceptance check passes and rollback remains available.
- Needs verification: implementation or deployment exists without complete
  live evidence.
- Blocked: the required mapping cannot preserve the current route safely.
- Scope exceeded: a solution would require unrelated APIs, ingress, or access.

## Non-goals

TLS, authentication, UDP, inbound IPv6, protocol parsing, destination changes,
and rating inflation through unrelated permissions.

## Baseline read set

- `docs/aegis/baseline/2026-07-11-initial-baseline.md`
- `docs/aegis/specs/2026-07-11-network-isolation-brief.md`
- `docs/aegis/plans/2026-07-11-network-isolation.md`
- `ha_forwarder/config.yaml`, `run.sh`, `apparmor.txt`, `DOCS.md`
- `tests/test_config.sh`, `tests/test_run.sh`
- Live Supervisor 2026.06.2 rating, options, and update behavior.

## Impact statement

Supervisor becomes the sole owner of host-port publication. Runtime behavior,
destination options, limits, timeout, boot, watchdog, and byte forwarding stay
unchanged. The only user-facing contract change is moving host-port selection
from Options to Network. The existing VM uses the default 5279, so its migration
is lossless.

## Risk hints

The port mapping must be persisted only after 0.3.0 metadata is active. Posting
it under 0.2.1 would filter the unknown key and persist an empty mapping.
