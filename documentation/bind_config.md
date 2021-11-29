[Back to resource list](../README.md#resources)

# bind_config

Creates the configuration files for the name server.

## Actions

| Action    | Description                                                                                                                             |
|-----------|-----------------------------------------------------------------------------------------------------------------------------------------|
| `:create` | Create the default configuration files (including RFC1912 zones), configure an rndc key, and set any query logging parameters required. |

## Properties

The `query_log` properties are deprecated and will be removed in a future version. Migrate to using the `bind_logging_channel` and `bind_logging_category` resources.

| Name                              | Type            | Default                                               | Description                                                                                                                                                                                                                     |
|-----------------------------------|-----------------|-------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `additional_config_files`         | Array           | `[]`                                                  | Array of additional config files to include in `named.conf`                                                                                                                                                                     |
| `bind_service`                    | String          | `default`                                             | Name of the `bind_service` resource to notify actions on                                                                                                                                                                        |
| `chroot_dir`                      | String          | see [`default_property_for`](../libraries/helpers.rb) | Define the chrooted base directory                                                                                                                                                                                              |
| `chroot`                          | `true`, `false` | `false`                                               | Configuring a chrooted nameserver                                                                                                                                                                                               |
| `conf_file`                       | String          | see [`default_property_for`](../libraries/helpers.rb) | The desired full path to the main configuration file                                                                                                                                                                            |
| `controls`                        | Array           | `[]`                                                  | Array of control statements                                                                                                                                                                                                     |
| `default_view`                    | String          | `default`                                             | The name of the default view to configure zones within when views are used                                                                                                                                                      |
| `ipv6_listen`                     | `true`, `false` | `true`                                                | Enables listening on IPv6 instances                                                                                                                                                                                             |
| `options`                         | Array           | `[]`                                                  | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.                                                                                                                                |
| `options_file`                    | String          | see [`default_property_for`](../libraries/helpers.rb) | The desired full path to the configuration file containing options                                                                                                                                                              |
| `per_view_additional_config_file` | Array           | `[]`                                                  | Array of additional per view config files to include in named.conf                                                                                                                                                              |
| `statistics_channel`              | Hash, Array     | `nil`                                                 | Presence turns on the statistics channel. Should be a hash containing `:address` and `:port` to configure the location where the statistics channel will listen on. This will likely move to a separate resource in the future. |
| `primaries`                       | Hash            | `{}`                                                  | List of name servers for which the server is secondary to, in the format `name => %w(list of ips)`. Can be referred to abbreviate `primaries` or `also-notify` in zones.                                                      |

The following properties are deprecated and will be removed in a future release of this cookbook:

| Name                 | Type            | Default | Description                                                                                |
|----------------------|-----------------|---------|--------------------------------------------------------------------------------------------|
| `query_log_max_size` | String          | `1m`    | Maximum size of query log before rotation                                                  |
| `query_log_options`  | Array           | `[]`    | Array of additional query log options                                                      |
| `query_log`          | String          | `nil`   | If provided will turn on general query logging. Should be the path to the desired log file |
| `query_log_versions` | String, Integer | `2`     | Number of rotated query logs to keep on the system                                         |

## Examples

```ruby
bind_config 'default'

bind_config 'default' do
  ipv6_listen false

  options [
    'recursion no',
    'allow-transfer { external-dns; }'
  ]
end

bind_config 'default' do
  statistics_channel address: 127.0.0.1, port: 8090

  query_log '/var/log/named/query.log'
  query_log_versions 5
  query_log_max_size '10m'
  query_log_options [
    'print-time yes'
  ]
end
```
