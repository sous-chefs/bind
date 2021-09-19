[Back to resource list](../README.md#resources)

# bind_server

This resource allows specific options to be configured for a particular upstream name server.

## Actions

| Action    | Description                                 |
| --------- | ------------------------------------------- |
| `:create` | Creates a BIND server with specific options |

## Properties

| Name          | Type   | Default   | Description                                                                                       |
| ------------- | ------ | --------- | ------------------------------------------------------------------------------------------------- |
| `bind_config` | String | `default` | Name of the `bind_config` resource to notify actions on                                           |
| `options`     | Array  | `[]`      | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.  |

## Examples

```ruby
bind_server '10.1.1.1' do
  options [
    'bogus yes'
  ]
end
```
