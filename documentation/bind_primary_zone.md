[Back to resource list](../README.md#resources)

# bind_primary_zone

This resource will copy a zone file from your current cookbook into the correct directory and add the zone as a master zone to your BIND configuration. The file should be named for the zone you wish to configure. For example to configure `example.com` the file should be in `files/default/example.com`

This resource also supports setting the action to `:create_if_missing`. In this event the cookbook will only copy a zone file in place if it does not already exist. Once copied the cookbook will not touch the file again allowing it to be used for dynamic updates. However, please be aware that in the event of the server being rebuilt or the file being removed that the data has not been persisted anywhere.

## Actions

| Action               | Description                                       |
| -------------------- | ------------------------------------------------- |
| `:create`            | Creates a BIND primary zone                       |
| `:create_if_missing` | Creates a BIND primary zone, only if it's missing |

## Properties

| Name          | Type   | Default                                               | Description                                                                                                                |
| ------------- | ------ | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `bind_config` | String | `default`                                             | Name of the `bind_config` resource to notify actions on                                                                    |
| `file_name`   | String | name property                                         | Name of the file to store the zone in. Used when you wish to have the same zone with different content in different views. |
| `options`     | Array  | `[]`                                                  | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.                           |
| `view`        | String | Defaults to the value from the `bind_config` property | Name of the view to configure the zone in                                                                                  |
| `zone_name`   | String |                                                       | The zone name of the zone. Used only if the name property does not match the zone name.                                    |

## Examples

```ruby
bind_view 'internal' do
  match_clients ['10.0.0.0/8']
  options ['recursion yes']
end

bind_view 'external' do
  options ['recursion no']
end
```
