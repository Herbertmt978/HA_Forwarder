# TCP Relay Rebrand Reflection

The safest rebrand boundary was the public display surface: keeping the
repository URL, App slug, AppArmor identity, and runtime contracts stable lets
Supervisor deliver 0.3.1 as an in-place update rather than a second App.

The branding regression test made that boundary executable. Its staged RED
sequence separated metadata work from documentation work, and independent
reviews caught ambiguous release wording and an unintended development-tag
rename before either reached a commit.

The problem-first README and early trust summary improve adoption without
turning the relay into a security product. The quick council found the
four-column configuration table acceptable, with narrow-screen behavior kept
as an observation item rather than speculative redesign work.

The live rollout confirmed that Supervisor treated 0.3.1 as an in-place update:
the slug, options, host-port mapping, security rating, bridge network, boot,
watchdog, and auto-update settings remained stable. A pre-update partial backup
and a controlled end-to-end handshake made the rollback and success paths
observable even though the normal device clients were offline.

AppArmor review corrected one earlier overbroad evidence claim. Both 0.3.0 and
0.3.1 show two non-blocking S6 directory-listing denials at startup. They are
not a rebrand regression, but future profile maintenance should either permit
the minimum directory reads or explicitly retain and document the denial
behavior.

The public presentation, release, and installed App now align on TCP Relay
without introducing a second runtime owner or compatibility adapter. The old
display name remains only where history, legal attribution, rollback metadata,
or the stable repository URL makes that record truthful.
