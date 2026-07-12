# AppArmor Startup-Denial Cleanup Intent

Date: 2026-07-12

## Requested outcome

Remove the two non-blocking AppArmor denials emitted when S6 lists
`/etc/fix-attrs.d/` and `/etc/services.d/` at startup. Preserve TCP Relay's
current behavior, Home Assistant security rating 6, bridge networking, options,
port mapping, and compatibility identity. Merge the reviewed fix, publish
version 0.3.2, update the existing Home Assistant VM, and prove the result.

## Scope

- The canonical AppArmor profile and its least-privilege regression contract.
- Patch-release metadata and changelog.
- Pull-request, exact-main CI, annotated tag, and GitHub Release verification.
- A rollback-protected in-place HAOS update and two cursor-bounded startup
  observations.
- Controlled TCP connections through Home Assistant to the configured Grott
  destination.

## Non-goals

- No runtime, option, schema, protocol, port, network, capability, API, slug,
  repository URL, or public-name change.
- No descendant rule for `/etc/fix-attrs.d/**`.
- No tightening of the pre-existing Home Assistant-standard
  `/etc/services.d/**` service-file rule in this focused correction.
- No rewrite of historical 0.3.0 or 0.3.1 rollout evidence.

## Root cause and authority

AppArmor directory objects require a rule that matches the trailing slash. The
existing `/etc/services.d/**` rule matched descendants, not the directory
itself, and no `/etc/fix-attrs.d/` directory rule existed. The observed S6
requests were exactly read (`r`) operations. The canonical owner is
`ha_forwarder/apparmor.txt`; `tests/test_config.sh` guards the intended policy.

## Success evidence and stop conditions

Success requires a red/green regression test, AppArmor compilation, the full
local and GitHub validation matrices, independent review, a matching v0.3.2
tag/release, a verified 0.3.1 partial backup, two starts with zero profile and
overall AppArmor denials after exact journal cursors, and successful
end-to-end relay connections.

Stop and restore the backup if the rating, custom profile, bridge network,
options, mapping, listener, or destination connection differs from the
captured 0.3.1 baseline. Also restore if either controlled 0.3.2 start produces
a TCP Relay profile denial or any other AppArmor denial in its post-cursor
window.
