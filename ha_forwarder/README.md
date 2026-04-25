# HA Forwarder

HA Forwarder listens on a TCP port on the Home Assistant host and forwards incoming traffic to another TCP service.

## Configuration

```yaml
listen_port: 5279
target_host: "example.local"
target_port: 5279
```

- `listen_port`: the TCP port Home Assistant should listen on.
- `target_host`: the hostname or IP address to forward traffic to.
- `target_port`: the TCP port on the target service.

The add-on uses host networking so the listen port can be changed directly in the add-on configuration.
