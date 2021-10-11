[Back to resource list](../README.md#resources)

# bind_stub_zone

This resource will configure bind to pull only the NS records for a zone from a primary name server.

## Actions

| Action    | Description              |
| --------- | ------------------------ |
| `:create` | Creates a BIND stub zone |

## Properties

| Name          | Type   | Default                                               | Description                                                                                                                |
| ------------- | ------ | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `bind_config` | String | `default`                                             | Name of the `bind_config` resource to notify actions on                                                                    |
| `file_name`   | String | name property                                         | Name of the file to store the zone in. Used when you wish to have the same zone with different content in different views. |
| `options`     | Array  | `[]`                                                  | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.                           |
| `primaries`   | Array  | required                                              | An array of IP addresses used as the upstream master for this zone. Is mandatory and has no default.                       |
| `view`        | String | Defaults to the value from the `bind_config` property | Name of the view to configure the zone in                                                                                  |
| `zone_name`   | String |                                                       | The zone name of the zone. Used only if the name property does not match the zone name.                                    |

## Examples

```ruby
bind_stub_zone 'example.com' do
  primaries [
    '10.1.1.1',
    '10.2.2.2'
  ]
end

bind_stub_zone 'example.org' do
  primaries [
    '10.1.1.1',
    '10.2.2.2'
  ]

  options [
    'zone-statistics full'
  ]
end
```
