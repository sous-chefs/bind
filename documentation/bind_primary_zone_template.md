[Back to resource list](../README.md#resources)

# bind_primary_zone_template

This resource will create a zone file from a template and list of desired resources.

This resource also supports setting the action to `:create_if_missing`. In this event the cookbook will only create a zone file in place if it does not already exist. Once copied the cookbook will not touch the file again allowing it to be used for dynamic updates. However, please be aware that in the event of the server being rebuilt or the file being removed that the data has not been persisted anywhere.

## Actions

| Action               | Description                                                       |
| -------------------- | ----------------------------------------------------------------- |
| `:create`            | Creates a BIND primary zone from a template                       |
| `:create_if_missing` | Creates a BIND primary zone from a template, only if it's missing |

## Properties

| Name                | Type            | Default                                      | Description                                                                                                                |
| ------------------- | --------------- | -------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `bind_config`       | String          | `default`                                    | Name of the `bind_config` resource to notify actions on                                                                    |
| `default_ttl`       | String, Integer | `86400`                                      | The default time to live for any records which do not have an explicitly configured TTL                                    |
| `file_name`         | String          | name property                                | Name of the file to store the zone in. Used when you wish to have the same zone with different content in different views. |
| `manage_serial`     | `true`, `false` | `false`                                      | A boolean indicating if we should manage the serial number. When `true` persists the current serial number and a digest of the current zone contents into the node object. If the records change the serial number will be incremented. The default serial number used is the value of `soa[:serial]`. |
| `options`           | Array           | `[]`                                         | Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.                           |
| `records`           | Array           | `[]`                                         | An array of hashes describing each desired record, see [below](#records) for supported keys                                |
| `soa`               | Hash            | `{}`                                         | Hash of SOA entries. see [below](#soa) for supported keys                                                                  |
| `template_cookbook` | String          | `bind`                                       | The cookbook to locate the primary zone template file                                                                      |
| `template_name`     | String          | `primary_zone.erb`                           | The name of the primary zone template file within a cookbook                                                               |
| `view`              | String          | Defaults to the value from the `bind_config` | Name of the view to configure the zone in                                                                                  |
| `zone_name`         | String          |                                              | The zone name of the zone. Used only if the name property does not match the zone name.                                    |

### records

Possible keys for the records parameter:

| Key     | Description                                                                      |
| ------- | -------------------------------------------------------------------------------- |
| `owner` | The name to be looked up                                                         |
| `rdata` | The value of the record. Freeform string that depends on the type for structure. |
| `ttl`   | A non-default TTL. If not present will use the default TTL of the zone.          |
| `type`  | The record type; examples include: `NS`, `MX`, `A`, `AAAA`.                      |

### soa

Possible keys for the records parameter:

| Key       | Default                 | Description                                                                                                         |
| --------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `serial`  | `1`                     | The serial number of the zone. <sup>[1](#ft1)</sup>                                                                 |
| `mname`   | `localhost`             | Domain name of the primary name server serving this zone.                                                           |
| `rname`   | `hostmaster.localhost.` | The email address of the "Responsible Person" for this zone with the @-sign replaced by a `.`.                      |
| `refresh` | `1w`                    | The period that a secondary name server will wait between checking if the zone file has been updated on the master. |
| `retry`   | `15m`                   | The period that a secondary name server will attempt to retry checking a zone file if the initial attempt fails.    |
| `expire`  | `52w`                   | The length of time that a zone will be considered invalid if the primary name server is unavailable.                |
| `minimum` | `30`                    | The length of time that a name server will cache a negative (`NXDOMAIN`) result.                                    |

<sup><a name="ft1">1</a>:  If this zone has secondary servers configured then you will need to either manually manage this and update when the record set changes, or use the `manage_serial` property.</sup>

## A note on serial numbers

Serial numbers are primarily used by the DNS to discover if a zone has changed and thus trigger a zone transfer by a secondary server. If you are managing all of the authoritative servers for a zone with chef then you do not need to change serial numbers when updating a zone. In this instance you can set a simple static serial number (`1` is used by default and is just fine).

On the other hand, if you have non-chef managed secondary servers then you will need to increment the serial number whenever the record set changes. This can be done in two different ways: manually (where you control the serial number set and will increment it each time the record set changes), or using the `manage_serial` property.

If you use the `manage_serial` property then each time the record set changes the serial number will be incremented. Providing a serial number in the `soa` property will be used as a default value for the serial number. When enabled this property will cause the cookbook to store the serial number and a hash of the record set in the host's node object. If you destroy the node object then this will result in the serial number being reset to the default value in the `soa` property. Finally, ensure that you only have a single server using the `manage_serial` property. Otherwise you may end up with different name servers with different serial numbers. In this case, set up a single node as the primary server and use the `bind_secondary_zone` on all the other authoritative servers to pull the zone from that designated primary server.

## Examples

```ruby
bind_primary_zone_template 'example.com' do
  soa serial: 100, minimum: 3600
  records [
    { type: 'NS', rdata: 'ns1.example.com.' },
    { owner: 'ns1', type: 'A', rdata: '10.0.1.1' }
  ]
end
```
