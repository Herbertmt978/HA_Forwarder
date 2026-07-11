# Home Assistant App: HA Forwarder

HA Forwarder listens for raw TCP connections on a fixed listener at container
TCP 5279. Home Assistant Supervisor publishes that listener on the Home
Assistant host, and HA Forwarder relays each connection to a single destination
service.

## Before you start

Confirm that:

- Home Assistant can resolve and reach the destination.
- The selected host port is unused on the Home Assistant host.
- The sender, Home Assistant, and destination are on networks you trust.
- The protocol is TCP. UDP is not supported.

## Configuration

```yaml
target_host: "example.local"
target_port: 5279
max_connections: 64
connect_timeout: 15
```

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `target_host` | Yes | None | Destination DNS name or IP address. Do not include a scheme or port. |
| `target_port` | No | `5279` | Destination TCP port. Valid range: 1–65535. |
| `max_connections` | No | `64` | Maximum simultaneous forwarding sessions. Valid range: 1–256. |
| `connect_timeout` | No | `15` | Seconds allowed to establish each destination connection. Valid range: 1–300. |

`target_host` cannot be blank and must not contain whitespace or commas.

After saving the configuration, start or restart HA Forwarder. A successful
start writes a line similar to this in the App log:

```text
[INFO] Forwarding TCP 5279 to example.local:5279 (max 64 connections, 15s connect timeout)
```

The container listener always remains TCP 5279. Supervisor maps it to host TCP
5279 by default. On version 0.3.0 or later, choose a different host port by
opening **Settings → Apps → HA Forwarder → Configuration** and changing the
host port beside `5279/tcp` in the **Network** section. Point the sending device
at the Home Assistant host address and that selected host port, then confirm
that the destination service receives its connection or data.

## Runtime behavior

- The listener binds to all IPv4 interfaces in the container's network
  namespace on container TCP 5279. That namespace is separate from the host
  and connected to a Supervisor-managed internal bridge network; Supervisor
  publishes the host port selected in the App's **Network** section.
- Each inbound connection creates one child process and one new destination
  connection.
- Once `max_connections` is reached, more sessions are not accepted until
  capacity becomes available.
- `connect_timeout` limits destination connection setup only. It does not
  close an established but idle connection.
- Data is relayed unchanged in both directions. It is not buffered for later
  delivery or replayed after a destination failure.
- The destination sees the Home Assistant host as the connection source; the
  original client's source address is not preserved.
- Configuration is read when the App starts. Restart after changing options or
  the Network port mapping.

## Security and limitations

HA Forwarder is a transport relay, not a security gateway. It provides no TLS,
authentication, client allowlist, rate limiting by source, traffic inspection,
or protocol validation. AppArmor restricts the container, but it does not
protect the TCP payload.

Version 0.3.0 removes host networking. Supervisor runs the container on a
Supervisor-managed internal bridge network within a network namespace separate
from the host. Its metadata has a calculated Supervisor security rating of 6,
compared with the live version 0.2.1 rating of 5; live version 0.3.0 validation
remains pending deployment. Only the shared host network namespace was
removed. The published TCP listener remains unauthenticated and plaintext.
Keep its host port on a trusted LAN and use the host or network firewall to
limit access. Never expose it directly to the internet unless another
appropriately secured network boundary protects it.

Do not configure the destination as the same Home Assistant host and published
host port as the listener. Obvious localhost loops on TCP 5279 are rejected at
startup, but aliases, other addresses that resolve back to the host, and loops
through a custom host port cannot be detected reliably.

Inbound IPv6 and UDP forwarding are not supported by the current listener.
IPv6 destination literals are supported.

## Troubleshooting

### The App will not start

- **`target_host must be set`**: enter a destination host, save, and restart.
- **`address already in use`**: another process is using the selected host
  port. Choose another host port in the App's **Network** section or stop the
  conflicting service.
- **Self-forwarding error**: use a destination other than the listener's own
  host and port.
- **Configuration range error**: correct the named option using the ranges in
  the table above.

### Clients connect but data does not arrive

- Confirm that `target_host` resolves from Home Assistant.
- Confirm that `target_port` is listening and allowed through the destination
  firewall.
- Try the destination's IPv4 address to separate DNS from connectivity
  problems.
- Check whether `max_connections` has been reached.
- Review the App log for `Connection refused`, timeout, or DNS errors.

### The repository or App is missing

Open **Settings → System → Logs**, select **Supervisor**, and look for
repository or configuration validation errors. Then return to the App store
and use **Check for updates**.

## Updating

Review [CHANGELOG.md](CHANGELOG.md) before updating. Version 0.3.0 is a
breaking configuration-surface change. Choose the path below that matches the
port used by the earlier version.

### Earlier version used a custom host port

If an earlier version used a custom `listen_port`, migrate in this order:

1. While the earlier version is still installed, record its `listen_port`,
   then stop the App.
2. Update to (or install) version 0.3.0. The `5279/tcp` **Network** row is
   supplied by version 0.3.0 and is not available in version 0.2.1. If the App
   starts automatically, stop it again before continuing.
3. Open **Settings → Apps → HA Forwarder → Configuration** and set the host
   port beside `5279/tcp` in the **Network** section to the value recorded in
   step 1. The container side remains TCP 5279.
4. Remove a stale `listen_port` key if Home Assistant still displays it, then
   save the remaining options and Network mapping.
5. Start or restart HA Forwarder, point the clients at the selected host port,
   and verify both the forwarding line in the App log and delivery to the
   destination service.

### Earlier version used the default host port

If the earlier version used the default TCP 5279, update directly to version
0.3.0 from **Settings → Apps**. After updating, confirm that the `5279/tcp`
host mapping remains 5279. Remove a stale `listen_port` key if Home Assistant
still displays it, save any changes, then start or restart HA Forwarder and
verify the forwarding log and destination delivery.

Existing valid destinations, connection limits, and timeouts remain unchanged.

## Support

Open a [GitHub issue](https://github.com/Herbertmt978/HA_Forwarder/issues) with:

- HA Forwarder version.
- Home Assistant version and installation type.
- Host architecture (`amd64` or `aarch64`).
- Redacted configuration.
- Reproduction steps and relevant App logs.

Do not include credentials, tokens, or unrelated Home Assistant logs.

HA Forwarder is licensed under the repository's [MIT License](../LICENSE).
