# bind_logging_channel

[Back to resource list](../README.md#resources)

This resource will configure a destination for logs to be sent to. To actually send logs you need to also configure a `bind_logging_category`.

## Actions

| Action    | Description                                |
|-----------|--------------------------------------------|
| `:create` | Creates a BIND logging destination channel |

## Properties

| Name             | Type                                     | Default   | Description                                                                                    | Valid Values  |
|------------------|------------------------------------------|-----------|------------------------------------------------------------------------------------------------|---|
| `bind_config`    | String                                   | `default` | Name of the `bind_config` resource to notify actions on                                        |  `stderr`, `syslog`, `file`, or `null`  |
| `destination`    | String                                   |           | String containing the destination name                                                         |   |
| `facility`       | String (Must be a valid syslog facility) |           | String containing the syslog facility to use for the syslog destination                        |   |
| `path`           | String                                   |           | File name used for the file destination                                                        |   |
| `print_category` | `true`, `false`                          | `false`   | Boolean representing if we should print the category in the output message                     |   |
| `print_severity` | `true`, `false`                          | `false`   | Boolean representing if we should print the severity of the log message to the output channel  |   |
| `print_time`     | `true`, `false`                          | `false`   | Boolean representing if we should print the time in the log message sent to the output channel |   |
| `severity`       | String                                   | `dynamic` | String containing the minimum severity of BIND logs to send to this channel                    |  critical, error, warning, notice, info, dynamic, or debug (this must be followed by a number representing the debug verbosity) |
| `size`           | String                                   |           | Maximum size of the log file used for the file destination                                     |   |
| `versions`       | Integer                                  |           | Number of versions of the log file used for the file destination                               |   |

## Examples

```ruby
bind_logging_channel 'querylog' do
  destination 'file'
  severity 'info'
  path '/tmp/query.log'
  versions 5
  size '10m'
  print_category true
  print_severity true
  print_time true
end

bind_logging_channel 'syslog' do
  destination 'syslog'
  facility 'daemon'
  severity 'info'
end
```
