# Migration Assistance

## Migrating from 1.x to 2.x

In version 2.x the BIND cookbook has become a library cookbook. Thus to use it
you should create a cookbook wrapper that configures the cookbook. All
configuration that was previously done by modifying attributes and recipes is
now done by customising the parameters given to the various resources.

The following table describes where each parameter is now configurable.

| Attribute | Replacement |
| --------- | ----------- |
| `bind['masters']` | Add individual entries on `bind_secondary_zone` resources |
| `bind['ipv6_listen']` | Use the ipv6\_listen property on `bind_config` |
| `bind['acl-role']` | Replaced by the `bind_acl` resource |
| `bind['acl']` | Replaced by the `bind_acl` resource |
| `bind['zones']` | Manage zones using the appropriate zone resources |
| `bind['forwardzones']` | Replace with the `bind_forward_zone` resource |
| `bind['forwarders']` | Replace with the `bind_forward_zone` resource |
| `bind['zonetype']` | Individually configurable per zone using the appropriate zone resource |
| `bind['zonesource']` | Removed. Replace with your own logic for finding the list of zones to manage |
| `bind['options']` | Add to the `options` property on the `bind_config` resource |
| `bind['allow_solo_search']` | Obsolete. Search has been entirely removed from the cookbook |
| `bind['enable_log']` | Replace with `query_log` parameter on the `bind_config` resource |
| `bind['log_file']` | Replace with `query_log` parameter on the `bind_config` resource |
| `bind['statistics-channel']` | Replaced with `statistics_channel` on the `bind_config` resource |
| `bind['statistics-port']` | Replaced with `statistics_channel` on the `bind_config` resource |
| `bind['statistics-address']` | Replaced with `statistics_channel` on the `bind_config` resource |
| `bind['server']` | Replaced with the `bind_server` resource |
| `bind['packages']` | Replaced by the `package_name` property on the `bind_service` resource |
| `bind['sysconfdir']` | Replaced by the `sysconfdir` property on the `bind_service` resource |
| `bind['conf_file']` | Replaced by the `conf_file` property on the `bind_service` resource |
| `bind['options_file']` | Replaced by the `options_file` property on the `bind_service` resource |
| `bind['vardir']` | Replaced by the `vardir` property on the `bind_service` resource |
| `bind['included_files']` | Removed. Add additional files via normal chef methods and include via the `options` property of `bind_config` |
| `bind['var_cookbook_files']` | Removed |
| `bind['rndc_keygen']` | Removed. The cookbook determines the correct invocation of this command to use |
| `bind['log_options']` | Replaced with the `query_log_options` property of the `bind_config` resource |
| `bind['rndc-key']` | Removed. We use only the platform default for this value. Can be readded if it is actually needed by anyone |
| `bind['ldap']` | Removed. Zone names and configurations should be provided with code outside of the cookbook |

### Data bag integration

Version 1.x allowed names of zones to be configured in an external system;
either a data bag, or a ldap server. This has been removed entirely, and you
can now perform a similar function by implementing the search logic yourself.
