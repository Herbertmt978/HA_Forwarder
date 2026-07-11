# Changelog

## 0.3.0

- Replace host networking with a Supervisor-managed internal bridge network
  and port mapping. Version 0.3.0 metadata calculates to security rating 6,
  compared with the live version 0.2.1 rating of 5.
- **Breaking:** remove the `listen_port` option and move host-port selection to
  the App's **Network** section. The default host port remains TCP 5279; users
  of a custom port must re-enter it there.
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
