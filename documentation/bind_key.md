[Back to resource list](../README.md#resources)

# bind_key

This resource adds a shared secret key (for either TSIG or the command channel) to the configuration.

## Actions

| Action    | Description                 |
| --------- | --------------------------- |
| `:create` | Creates a shared secret key |

## Properties

| Name          | Type   | Default   | Description                                             |
| ------------- | ------ | --------- | ------------------------------------------------------- |
| `algorithm`   | String |           | The algorithm that the secret key was generated from    |
| `bind_config` | String | `default` | Name of the `bind_config` resource to notify actions on |
| `secret`      | String |           | The secret key                                          |

## Examples

```ruby
bind_key 'dns-update-key' do
  algorithm 'hmac-sha256'
  secret 'this_is_the_secret_key'
end
```
