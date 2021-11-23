[Back to resource list](../README.md#resources)

# bind_primary_zone

This resource will copy a zone file from your current cookbook into the correct directory and add the zone as a master zone to your BIND configuration. The file should be named for the zone you wish to configure. For example to configure `example.com` the file should be in `files/default/example.com`, or set manually with `source_file`.

This resource also supports setting the action to `:create_if_missing`. In this event the cookbook will only copy a zone file in place if it does not already exist. Once copied the cookbook will not touch the file again allowing it to be used for dynamic updates. However, please be aware that in the event of the server being rebuilt or the file being removed that the data has not been persisted anywhere.

If the zone file is managed completely externally, `:create_config_only` will not manage the file at all and only create the zone entry in the BIND config.

## Actions

| Action                | Description                                                                   |
| --------------------- | ----------------------------------------------------------------------------- |
| `:create`             | Creates a BIND primary zone                                                   |
| `:create_if_missing`  | Creates a BIND primary zone, only if it's missing                             |
| `:create_config_only` | Creates the BIND config entry only and does not try to manage the file at all |

## Properties

| Name          | Type   | Default                                               | Description                                                                                                                |
| ------------- | ------ | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `bind_config` | String | `default`                                             | Name of the `bind_config` resource to notify actions on                                                                    |
| `file_name`   | String | name property                                         | Name of the file to store the zone in. Used when you wish to have the same zone with different content in different views. |
| `options`     | Array  | `[]`                                                  | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.                           |
| `view`        | String | Defaults to the value from the `bind_config` property | Name of the view to configure the zone in                                                                                  |
| `zone_name`   | String |                                                       | The zone name of the zone. Used only if the name property does not match the zone name.                                    |
| `source_file` | String |                                                       | Filename to source the zonefile from. Passed to `source` property of `cookbook_file`                                       |

## Examples

```ruby
# to load zone from files/db.example.org
bind_primary_zone 'example.org'

# or from custom file
bind_primary_zone 'example.org' do
  source_file 'other-example.org'
end
```
