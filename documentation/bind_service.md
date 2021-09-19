[Back to resource list](../README.md#resources)

# bind_service

Installs the pre-requisites for the bind service to run.

## Actions

| Action     | Description                                                                                                                 |
| ---------- | --------------------------------------------------------------------------------------------------------------------------- |
| `:create`  | Installs packages and creates appropriate configuration directories. It does not attempt to create a working configuration. |
| `:start`   | Ensures that the name server will be started at the end of the Chef run and will be started automatically on boot.          |
| `:restart` | Immediately restart the name server                                                                                         |

## Properties

| Name           | Type            | Default                                               | Description                                                                                                                 |
| -------------- | --------------- | ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `chroot_dir`   | String          | see [`default_property_for`](../libraries/helpers.rb) | Define the chrooted base directory. Affects `sysconfdir` and `vardir` and is platform specific.                             |
| `chroot`       | `true`, `false` | `false`                                               | Boolean declaration to setup a chrooted nameserver installation                                                             |
| `dynamicdir`   | String          | see [`default_property_for`](../libraries/helpers.rb) | Directory location for storing zones used with dynamic updates                                                              |
| `package_name` | String, Array   | see [`default_property_for`](../libraries/helpers.rb) | The package, or array of packages, needed to install the nameserver. Usually includes bind and associated utility packages. |
| `run_group`    | String          | see [`default_property_for`](../libraries/helpers.rb) | The groups that the name server will run as                                                                                 |
| `run_user`     | String          | see [`default_property_for`](../libraries/helpers.rb) | The user that the name server will run as                                                                                   |
| `service_name` | String          | see [`default_property_for`](../libraries/helpers.rb) | The name of the service installed by the system packages                                                                    |
| `sysconfdir`   | String          | see [`default_property_for`](../libraries/helpers.rb) | The system configuration directory where the named config will be located                                                   |
| `vardir`       | String          | see [`default_property_for`](../libraries/helpers.rb) | The location for zone files and other data                                                                                  |

## Examples

```ruby
bind_service 'default' do
  action [:create, :start]
end
```
