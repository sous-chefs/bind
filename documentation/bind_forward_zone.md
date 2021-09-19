[Back to resource list](../README.md#resources)

# bind_forward_zone

This resource will configure a forwarding only zone.

## Actions

| Action    | Description                 |
| --------- | --------------------------- |
| `:create` | Creates a BIND forward zone |

## Properties

| Name          | Type                       | Default                                               | Description                                                                                                                      |
| ------------- | -------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `bind_config` | String                     | `default`                                             | Name of the `bind_config` resource to notify actions on                                                                          |
| `forward`     | String (`only` or `first`) | `only`                                                | Set to `first` if you wish to try a regular lookup if forwaridng fails. `only` will cause the query to fail if forwarding fails. |
| `forwarders`  | Array                      | `[]`                                                  | An array of IP addresses to which requests for this zone will be forwarded to. An empty array will disable forwarding for this zone if globally configured |
| `view`        | String                     | Defaults to the value from the `bind_config` property | Name of the view to configure the zone in                                                                                        |

## Examples

```ruby
bind_forward_zone 'example.com' do
  forwarders [
    '10.1.1.1',
    '10.2.2.2'
  ]
end

bind_forward_zone 'example.org' do
  forward 'first'
  forwarders ['10.0.1.1', '10.2.1.1']
end
```
