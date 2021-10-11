[Back to resource list](../README.md#resources)

# bind_view

Configures a BIND view and allows you to serve different content to different clients.

## Actions

| Action    | Description         |
| --------- | ------------------- |
| `:create` | Creates a BIND view |

## Properties

| Name                    | Type            | Default   | Description                                                                                       |
| ----------------------- | --------------- | --------- | ------------------------------------------------------------------------------------------------- |
| `bind_config`           | String          | `default` | Name of the `bind_config` resource to notify actions on                                           |
| `match_clients`         | Array           | `[]`      | Serve the content of this view to any client matching an IP address in this list                  |
| `match_destinations`    | Array           | `[]`      | Serve the content of this view to any request arriving on this IP address                         |
| `match_recursive_only`  | `true`, `false` | `false`   | Match on any recursive requests                                                                   |
| `options`               | Array           | `[]`      | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.  |

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
