# BIND [![Build Status](https://secure.travis-ci.org/joyofhex/cookbook-bind.png?branch=master)](http://travis-ci.org/joyofhex/cookbook-bind)

## Description

A chef cookbook to manage BIND servers and zones.

## Contents

<!-- vim-markdown-toc GFM -->

* [Requirements](#requirements)
* [Attributes](#attributes)
* [Usage](#usage)
  * [Internal recursive nameserver](#internal-recursive-nameserver)
  * [Authoritative primary nameserver](#authoritative-primary-nameserver)
  * [Authoritative secondary nameserver](#authoritative-secondary-nameserver)
* [Available Custom Resources](#available-custom-resources)
  * [`bind_service`](#bind_service)
    * [Example](#example)
    * [Properties](#properties)
  * [`bind_config`](#bind_config)
    * [Examples](#examples)
    * [Properties](#properties-1)
  * [`bind_primary_zone`](#bind_primary_zone)
    * [Examples](#examples-1)
    * [Properties](#properties-2)
  * [`bind_primary_zone_template`](#bind_primary_zone_template)
    * [Examples](#examples-2)
    * [Properties](#properties-3)
  * [`bind_secondary_zone`](#bind_secondary_zone)
    * [Examples](#examples-3)
    * [Properties](#properties-4)
  * [`bind_forwarder`](#bind_forwarder)
    * [Examples](#examples-4)
    * [Properties](#properties-5)
  * [`bind_acl`](#bind_acl)
    * [Examples](#examples-5)
    * [Properties](#properties-6)
  * [`bind_key`](#bind_key)
    * [Properties](#properties-7)
  * [`bind_server`](#bind_server)
    * [Examples](#examples-6)
    * [Properties](#properties-8)
* [License and Author](#license-and-author)

<!-- vim-markdown-toc -->

## Requirements

This release migrates to using custom resources. Thus we require a more recent
version of chef (12.16 or above). To continue using this cookbook on older
versions please stick with the 1.x versions.

This cookbook now follows the library pattern. To use the cookbook effectively
you'll need a wrapper cookbook that has the resources listed.

A default recipe is provided. It only provides a basic recursive name server.

## Attributes

Most attributes have been removed in favour of custom resources.
See the MIGRATION.md document.

## Usage

Using custom resources leads to a quite flexible configuration, but requires
a little bit more work in a wrapper cookbook to use. The following examples 
are presented here:

- Internal recursive nameserver
- Authoritative primary nameserver
- Authoritative secondary nameserver

### Internal recursive nameserver

```ruby
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  ipv6_listen true
  options [
    'check-names slave ignore',
    'multi-master yes',
    'provide-ixfr yes',
    'recursive-clients 10000',
    'request-ixfr yes',
    'allow-notify { acl-dns-masters; acl-dns-slaves; }',
    'allow-query { example-lan; localhost; }',
    'allow-query-cache { example-lan; localhost; }',
    'allow-recursion { example-lan; localhost; }',
    'allow-transfer { acl-dns-masters; acl-dns-slaves; }',
    'allow-update-forwarding { any; }',
  ]
end

bind_acl 'acl-dns-masters' do
  entries [
    '! 10.1.1.1',
    '10/8'
  ]
end

bind_acl 'acl-dns-slaves' do
  entries [
    'acl-dns-masters'
  ]
end

bind_acl 'example-lan' do
  entries [
    '10.2/16',
    '10.3.2/24',
    '10.4.3.2'
  ]
end
```

### Authoritative primary nameserver

There are two ways to create primary zone files with this cookbook. The first
is by providing a complete zone file that is placed in the correct directory
(and is added to the nameserver configuration by using the
`bind_primary_zone` resource). The second way is by using the
`bind_primary_zone_template` resource. To use this you need to provide
an array of hashes containing the records you want to be added to the zone file.

The following example has both options shown. In a wrapper cookbook add the code below with appropriate modifications.

You'll need to configure the ACL entries (and names) for the example-lan and
acl-dns-masters ACLs for your local configuration.

You will also need to arrange for the zone files to be placed in the configured
location (which is OS dependent by default).

Resource style:

```ruby
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  ipv6_listen true
  options [
    'recursion no',
    'allow-query { any; }',
    'allow-transfer { external-private-interfaces; external-dns; }',
    'allow-notify { external-private-interfaces; external-dns; localhost; }',
    'listen-on-v6 { any; }'
  ]
end

bind_acl 'external-private-interfaces' do
  entries [
  ]
end

bind_acl 'external-dns' do
  entries [
  ]
end

cookbook_file '/var/named/primary/db.example.com' do
  owner 'named'
  group 'named'
  mode '0440'
  action :create
end

bind_primary_zone 'example.com'

bind_primary_zone_template 'example.org' do
  soa serial: 100
  default_ttl 200
  records [
    { type: 'NS', rdata: 'ns1.example.org.' },
    { type: 'NS', rdata: 'ns2.example.org.' },
    { type: 'MX', rdata: '10 mx1.example.org.' },
    { type: 'MX', rdata: '20 mx1.example.org.' },
    { owner: 'www', type: 'A', ttl: 20, rdata: '10.5.0.1' },
    { owner: 'ns1', type: 'A', ttl: 20, rdata: '10.5.1.1' },
    { owner: 'ns2', type: 'A', ttl: 20, rdata: '10.5.2.1' },
    { owner: 'mx1', type: 'A', ttl: 20, rdata: '10.5.1.100' },
    { owner: 'mx2', type: 'A', ttl: 20, rdata: '10.5.2.100' },
  ]

```

### Authoritative secondary nameserver

In a wrapper cookbook add the code below with appropriate modifications.

You'll need to configure the ACL entries (and names) for the example-lan and
acl-dns-masters ACLs for your local configuration.

```ruby
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  ipv6_listen true
  options [
    'recursion no',
    'allow-query { any; }',
    'allow-transfer { external-private-interfaces; external-dns; }',
    'allow-notify { external-private-interfaces; external-dns; localhost; }',
    'listen-on-v6 { any; }'
  ]
end

bind_acl 'acl-dns-masters' do
  entries [
    '! 10.1.1.1',
    '10/8'
  ]
end

bind_acl 'acl-dns-slaves' do
  entries [
    'acl-dns-masters'
  ]
end

bind_acl 'example-lan' do
  entries [
    '10.2/16',
    '10.3.2/24',
    '10.4.3.2'
  ]
end

bind_secondary_zone 'example.com' do
  primaries %w(192.0.2.10 192.0.2.11 192.0.2.12)
end

bind_secondary_zone 'example.org' do
  primaries %w(192.0.2.10 192.0.2.11 192.0.2.12)
end
```

## Available Custom Resources

### `bind_service`

The `bind_service` resource installs the pre-requisites for the service to run.

The `:create` action installs packages and creates appropriate configuration
directories. It does not attempt to create a working configuration.

The `:start` action ensures that the name server will be started at the end of
the chef run and will be started automatically on boot.

The `:restart` wil immediately restart the name server.

#### Example

```ruby
bind_service 'default' do
  action [:create, :start]
end
```

#### Properties

The following properties are supported:

* `sysconfdir` - The system configuration directory where the named config will be located. The default is platform specific. Usually `/etc/named` or `/etc/bind`
* `vardir` - The location for zone files and other data. The default is platform specific, usually `/var/named` or `/var/cache/bind`.
* `package_name` - The package, or array of packages, needed to install the nameserver. Default is platform specific, usually includes bind and associated utility packages.
* `run_user` - The user that the name server will run as. Defaults to `named`.
* `run_group` - The groups that the name server will run as. Defaults to `named`.
* `service_name` - The name of the service installed by the system packages. Defaults to a platform specific value.

### `bind_config`

The `bind_config` resource creates the configuration files for the name server.

The only available action is `:create` which will create the default
configuration files (including RFC1912 zones), configure an rndc key, and
set any query logging parameters required.

#### Examples

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

#### Properties

* `conf_file` - The desired full path to the main configuration file. Platform specific default.
* `options_file` - The desired full path to the configuration file containing options. Platform specific default.
* `ipv6_listen` - Enables listening on IPv6 instances. Can be true or false. Defaults to true.
* `options` - Array of option strings. Each option should be a valid BIND option minus the trailing semicolon. Defaults to an empty array.
* `query_log` - If provided will turn on general query logging. Should be the path to the desired log file. Default is empty and thus disabled. This will likely move to a separate resource in the future.
* `query_log_max_size` - Maximum size of query log before rotation. Defaults to '1m'.
* `query_log_versions` - Number of rotated query logs to keep on the system. Defaults to 2.
* `query_log_options` - Array of additional query log options. Defaults to empty array.
* `statistics_channel` - Presence turns on the statistics channel. Should be a hash containing :address and :port to configure the location where the statistics channel will listen on. This will likely move to a separate resource in the future.

### `bind_primary_zone`

The `bind_primary_zone` resource will copy a zone file from your current
cookbook into the correct directory and add the zone as a master zone to your
BIND configuration. The file should be named for the zone you wish to configure.
For example to configure `example.com` the file should be in
`files/default/example.com`

#### Examples

```ruby
bind_primary_zone 'example.com'

bind_primary_zone 'example.org' do
  options [
    'allow-transfer { none; }'
  ]
end
```

#### Properties

* `options` - An array of zone options. Defaults to an empty array.

### `bind_primary_zone_template`

The `bind_primary_zone_template` resource will create a zone file from a
template and list of desired resources.

#### Examples

```ruby
bind_primary_zone_template 'example.com' do
  soa serial: 100, minimum: 3600
  records [
    { type: 'NS', rdata: 'ns1.example.com.' },
    { owner: 'ns1', type: 'A', rdata: '10.0.1.1' }
  ]
end
```

#### Properties

* `soa` - Hash of SOA entries. Available keys are:
  - `:serial` - The serial number of the zone. Defaults to '1'. If this zone 
  has secondary servers configured then you will need to manually manage this
  and update when the record set changes.
  - `:mname` - Domain name of the primary name server serving this zone. Defaults to 'localhost.'
  - `:rname` - The email address of the "Responsible Person" for this zone with the @-sign replaced by a `.`. Defaults to `hostmaster.localhost.`
  - `:refresh` - The period that a secondary name server will wait between checking if the zone file has been updated on the master. Defaults to '1w'.
  - `:retry` - The period that a secondary name server will attempt to retry checking a zone file if the initial attempt fails. Defaults to '15m'.
  - `:expire` - The length of time that a zone will be considered invalid if the primary name server is unavailable. Defaults to '52w'.
  - `:minimum` - The length of time that a name server will cache a negative (NXDOMAIN) result. Defaults to 30 seconds.
* `default_ttl` - The default time to live for any records which do not have an explicitly configured TTL.
* `records` - An array of hashes describing each desired record. Possible keys are:
  - `:owner` - The name to be looked up.
  - `:type` - The record type; examples include: 'NS', 'MX', 'A', 'AAAA'.
  - `:ttl` - A non-default TTL. If not present will use the default TTL of the zone.
  - `:rdata` - The value of the record. Freeform string that depends on the type for structure.
* `template_cookbook` - The cookbook to locate the primary zone template file. Defaults to 'bind'. You can override this to change the structure of the zone file.
* `template_name` - The name of the primary zone template file within a cookbook. Defaults to 'primary\_zone.erb'

### `bind_secondary_zone`

The `bind_secondary_zone` resource will configure a zone to be pulled from a
primary name server.

#### Examples

```ruby
bind_secondary_zone 'example.com' do
  primaries [
    '10.1.1.1',
    '10.2.2.2'
  ]
end

bind_secondary_zone 'example.org' do
  primaries [
    '10.1.1.1',
    '10.2.2.2'
  ]

  options [
    'zone-statistics full'
  ]
end
```

#### Properties

* `primaries` - An array of IP addresses used as the upstream master for this zone. Is mandatory and has no default.
* `options` - An optional array of options to be added directly to the zone configuration. Default is empty.

### `bind_forwarder`

The `bind_forwarder` resource will configure a forwarding only zone.

#### Examples

```ruby
bind_forwarder 'example.com' do
  forwarders [
    '10.1.1.1',
    '10.2.2.2'
  ]
end

bind_forwarder 'example.org' do
  forward 'first'
  forwarders ['10.0.1.1', '10.2.1.1']
end
```

#### Properties

* `forwarders` - An array of IP addresses to which requests for this zone will
  be forwarded to. Defaults to an empty list. (Which if set will disable
  forwarding for this zone if globally configured).
* `forward` - Set to 'first' if you wish to try a regular lookup if forwaridng fails. 'only' will cause the query to fail if forwarding fails. Default is 'only'.


### `bind_acl`

The `bind_acl` resource allows you to create a named ACL list within the
BIND configuration.

#### Examples

```ruby
bind_acl 'google-dns-servers' do
  entries [
    '8.8.8.8',
    '8.8.4.4'
  ]
end

bind_acl 'internal-dns' do
  entries [
    '! 10.1.1.1',
    '10/8'
  ]
end

bind_acl 'tsig_key' do
  entries [
    'key "internal-key"',
  ]
end
```
#### Properties

* `entries` - An array of strings representing each acl entry.

Each entry should be a valid BIND address match list. This means it can be:

- an IP address
- an IP prefix
- a key id
- the name of a different address march list from another acl statement
- a nested address match list enclosed in braces

Predefined ACLs (from BIND itself) which do not need additional configuration are: any, none, localhost, and localnets.

### `bind_key`

The `bind_key` resource adds a shared secret key (for either TSIG or
the command channel) to the configuration.

```ruby
bind_key 'dns-update-key' do
  algorithm 'hmac-sha256'
  secret 'this_is_the_secret_key'
end
```

#### Properties

* `algorithm` - The algorithm that the secret key was generated from.
* `secret` - The secret key

### `bind_server`

The `bind_server` resource allows specific options to be configured for a
particular upstream name server.

#### Examples

```ruby
bind_server '10.1.1.1' do
  options [
    'bogus yes'
  ]
end
```

#### Properties

* `options` - An array of options which will be rendered into the configuration.


## License and Author

- Copyright: 2011 Eric G. Wolfe
- Copyright: 2017 David Bruce

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
