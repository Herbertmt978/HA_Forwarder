# Home Assistant App: HA Forwarder

HA Forwarder listens for raw TCP connections on the Home Assistant host and
relays each connection to a single destination service.

## Before you start

Confirm that:

- Home Assistant can resolve and reach the destination.
- The listen port is unused on the Home Assistant host.
- The sender, Home Assistant, and destination are on networks you trust.
- The protocol is TCP. UDP is not supported.

## Configuration

```yaml
listen_port: 5279
target_host: "example.local"
target_port: 5279
max_connections: 64
connect_timeout: 15
```

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `listen_port` | No | `5279` | TCP port to open on the Home Assistant host. Valid range: 1–65535. |
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

Point the sending device at the Home Assistant host address and `listen_port`,
then confirm that the destination service receives its connection or data.

## Runtime behavior

- The listener binds to all IPv4 interfaces because the App uses host
  networking.
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
- Configuration is read when the App starts. Restart after changing options.

## Security and limitations

HA Forwarder is a transport relay, not a security gateway. It provides no TLS,
authentication, client allowlist, rate limiting by source, traffic inspection,
or protocol validation. AppArmor restricts the container, but it does not
protect the TCP payload.

Keep the listen port on a trusted LAN and use the host or network firewall to
limit access. Never expose it directly to the internet unless another
appropriately secured network boundary protects it.

Do not configure the destination as the same Home Assistant host and port as
the listener. Obvious localhost loops are rejected at startup, but aliases or
other addresses that resolve back to the host cannot be detected reliably.

Inbound IPv6 and UDP forwarding are not supported by the current listener.
IPv6 destination literals are supported.

## Troubleshooting

### The App will not start

- **`target_host must be set`**: enter a destination host, save, and restart.
- **`address already in use`**: another process is using `listen_port`. Choose
  another port or stop the conflicting service.
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

Review [CHANGELOG.md](CHANGELOG.md), update HA Forwarder from
**Settings → Apps**, and verify the forwarding line in the App log after the
restart. Version 0.2.0 keeps existing valid destinations working and supplies
defaults for the new connection limits.

## Support

Open a [GitHub issue](https://github.com/Herbertmt978/HA_Forwarder/issues) with:

- HA Forwarder version.
- Home Assistant version and installation type.
- Host architecture (`amd64` or `aarch64`).
- Redacted configuration.
- Reproduction steps and relevant App logs.

Do not include credentials, tokens, or unrelated Home Assistant logs.

HA Forwarder is licensed under the repository's [MIT License](../LICENSE).
