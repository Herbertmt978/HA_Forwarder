# Changelog

## 0.3.2

- Allow S6 to list the `/etc/fix-attrs.d/` and `/etc/services.d/` directories
  using exact, read-only AppArmor rules. This removes two non-blocking denials
  at startup without granting access beneath `/etc/fix-attrs.d/` or changing
  the existing service-file rules.
- This release makes no option, port, forwarding, or migration change.

## 0.3.1

- The repository/README title is now `TCP Relay for Home Assistant`, and the
  Home Assistant App display name is now `TCP Relay`.
- This release makes no option, port, runtime, or migration change.

## 0.3.0

- Replace host networking with a Supervisor-managed internal bridge network
  and port mapping. Version 0.3.0 metadata calculates to security rating 6,
  compared with version 0.2.1's observed rating of 5.
- **Breaking:** remove the `listen_port` option and move host-port selection to
  the App's **Network** section. The default host port remains TCP 5279; users
  of a custom port must re-enter it there.
- **Breaking:** loopback and other local-only destinations now refer to the App
  container. Before upgrading, replace values including `localhost`,
  `localhost.`, `localhost.localdomain`, any `127.0.0.0/8` address,
  `0.0.0.0`, and `::1` or `[::1]` with a hostname or IP address reachable
  from the App container. This migration does not apply to direct routes to
  separate LAN hosts; verify every route after upgrading.
- Keep the container listener fixed at TCP 5279 and remove the no-longer-needed
  AppArmor `net_bind_service` capability.

## 0.2.1

- Restore option compatibility with Home Assistant Supervisor when saving a target host.

## 0.2.0

- Require and validate the target before starting the forwarder.
- Add configurable connection and target connection-timeout limits.
- Update the Home Assistant base images and simplify the container build.
- Tighten the AppArmor profile by removing blanket filesystem access.
- Add configuration translations, complete operating documentation, tests, and CI.

## 0.1.1

- Add a custom AppArmor profile for tighter runtime confinement.

## 0.1.0

- Initial release.
