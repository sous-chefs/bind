[Back to resource list](../README.md#resources)

# bind_logging_category

This resource maps BIND logging categories to logging channels.

## Actions

| Action    | Description                     |
| --------- | ------------------------------- |
| `:create` | Creates a BIND logging category |

## Properties

| Name          | Type                        | Default       | Description                                                                 |
| ------------- | --------------------------- | ------------- | --------------------------------------------------------------------------- |
| `bind_config` | String                      | `default`     | Name of the `bind_config` resource to notify actions on                     |
| `category`    | String <sup>[1](#ft1)</sup> | name property | Name of the BIND logging category to send to the specified channels         |
| `channels`    | Array, String               | required      | Array of names (or single name) of channels to send the category of logs to |

<sup><a name="ft1">1</a> Must be a valid BIND logging category`</sup>

## Examples

```ruby
bind_logging_category 'queries' do
  channels ['syslog', 'querylog']
end

bind_logging_category 'xfer-in' do
  channels 'syslog'
end
```
