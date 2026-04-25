# HA Forwarder

A small Home Assistant add-on for forwarding TCP traffic from the Home Assistant host to another TCP service.

Use it when a device can only send traffic to your Home Assistant address, but the service that should receive that traffic runs elsewhere.

## Installation

1. In Home Assistant, go to Settings -> Add-ons -> Add-on Store.
2. Open the three-dot menu and choose Repositories.
3. Add this repository URL:

   ```text
   https://github.com/Herbertmt978/HA_Forwarder
   ```

4. Install the **HA Forwarder** add-on.

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
