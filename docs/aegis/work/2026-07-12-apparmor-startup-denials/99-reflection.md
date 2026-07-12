# AppArmor Startup-Denial Cleanup Reflection

The denial records already described the smallest correct change: two fixed
directory objects, one read operation, and one S6 caller. Following those facts
avoided the tempting but unnecessary `/etc/fix-attrs.d/**` subtree grant and
preserved the existing rating-6 confinement boundary.

The red test proved that the repository did not express the required directory
access. Review then exposed a subtler policy-test risk: AppArmor accepts quoted,
qualified, and access-first rule forms, and permissions are additive. Requiring
one canonical rule and one total path occurrence turned the test into a useful
least-privilege guard instead of a simple substring check.

Static compilation could prove syntax but not Supervisor's generated profile
identity or HAOS audit behavior. Exact journal cursors around two starts made
the runtime claim falsifiable: both windows contained zero profile denials and
zero AppArmor denials overall. Controlled connections after each start proved
that silence did not come from a relay that failed to launch.

The update preserved the installed slug, options, mapped port, security rating,
bridge network, boot policy, watchdog, and auto-update setting. The new release
therefore retires startup noise without introducing a second owner, compatibility
adapter, or forwarding behavior change.
