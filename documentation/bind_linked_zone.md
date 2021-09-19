[Back to resource list](../README.md#resources)

# bind_linked_zone

This resource will create a zone linked to a zone with the same name in a different view, using the BIND in-view directive. The in-view directive requires BIND 9.10 or higher.

## Actions

| Action    | Description                |
| --------- | -------------------------- |
| `:create` | Creates a BIND linked zone |

## Properties

| Name          | Type   | Default                                               | Description                                                                                                                                           |
| ------------- | ------ | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bind_config` | String | `default`                                             | Name of the `bind_config` resource to notify actions on                                                                                               |
| `in_view`     | String |                                                       | The view of the zone to reference                                                                                                                     |
| `view`        | String | Defaults to the value from the `bind_config` property | Name of the view to configure the zone in                                                                                                             |
| `zone_name`   | String |                                                       | The name of the zone. Used only if the name property does not match the zone name. Must be identical to the name of the zone that is being linked to. |

## Examples

```ruby
bind_primary_zone 'sub.example.com' do
  view 'internal'
end

bind_linked_zone 'sub.example.com' do
  in_view 'internal'
  view 'external'
end
```
