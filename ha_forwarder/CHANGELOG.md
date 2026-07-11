# Changelog

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
