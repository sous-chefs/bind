# Bind

## Description

A cookbook to manage bind DNS servers, and zones.

## Requirements

Included ldap2zone recipe depends on Chef 0.10.10 features,
such as `chef_gem`.

The net-ldap v0.2.2 Ruby gem is required for the ldap2zone recipe.

## Attributes

### Attributes which probably require tuning

* `bind['masters']`
  - Array of authoritative servers which you transfer zones from.
  - Default empty

* `bind['ipv6_listen']`
  - Boolean, whether BIND should listen on ipv6
  - Default is false

* `bind['acl-role']`
  - Search key for pulling split-domain ACLs out of `data_bags`
  - Defaults to internal-acl, and has no effect if you do not need ACLs.

* `bind['acl']`
  - An array node attribute which `data_bag` ACLs are pushed on to,
    and then passed to named.options template.
  - Default is an empty array.

* `bind['zones']`
  - An array node attribute which zone names are pushed on to,
    from an external source such as `data_bags` or even LDAP
  - Defaults to an empty array.  See ldap2zone, or databag2zone
    recipes, for examples on populating your named.conf template
    from an external data source.

* `bind['zonetype']`
  - The zone type, master, or slave for configuring
    the  named.conf template.
  - Defaults to slave

* `bind['zonesource']`
  - The external zone data source, included examples are databag
    or ldap
  - Defaults to databag.  Should have no effect if no zone names
    exist in the bind `data_bag`.

* `bind['options']`
  - Free form options for named.conf template
  - Defaults to an empty array.

### Attributes which should not require tuning

* `bind['packages']`
  - packages to install
  - Platform specific defaults

* `bind['sysconfdir']`
  - etc directory for named
  - Platform specific defaults

* `bind['vardir']`
  - var directory for named to write state data, such as zone files.
  - Platform specific defaults

* `bind['etc_cookbook_files']`
  - static cookbook files to drop off in sysconf directory
  - Defaults to named.rfc1912.zones

* `bind['etc_template_files']`
  - template files to render from `data_bag` and/or roles
  - Defaults to named.options

* `bind['var_cookbook_files']`
  - static cookbook files to drop off in var directory
  - defaults to named.empty, named.ca, named.loopback, and named.localhost

* `bind['rndc_keygen']`
  - command to generate rndc key
  - default depends on hardware/hypervisor platform

### ldap2zone recipe specific attributes

We store our zone names on Active Directory, and use Ruby to pull
these into Chef and configure our Linux BIND servers.  If you already
have Active Directory, chances are you have an authoritative data
source for zone names in LDAP and can use this recipe to query
this data, just by setting a few attributes in a role.

* `bind['ldap']['binddn']`
   - The binddn username for connecting to LDAP
   - Default nil

* `bind['ldap']['bindpw']`
  - The binddn password for connecting to LDAP
  - Default nil

* `bind['ldap']['filter']`
  - The LDAP object filter for zone names
  - Defaults to dnsZone class, excluding Root DNS Servers

* `bind['ldap'][server']`
  - The authoritative directory server for your domain
  - Defaults to nil

* `bind['ldap']['domainzones']`
  - The LDAP tree where your domain zones are located
  - Defaults to the Active Directory zone tree for example.com.

## Usage

  Set up a role for 

```ruby
name "internal_dns"
description "Configure and install Bind to function as an internal DNS server."
override_attributes "bind" => {
  "masters" => [ "10.101.4.29", "10.101.4.30", "10.101.4.26" ],
  "ipv6_listen" => true,
  "zonetype" => "slave",
  "zonesource" => "ldap",
  "zones" => [
    "som.marshall.edu",
    "0.103.10.in-addr.arpa",
    "wvrhepahec.org"
  ],
  "ldap" => {
    "server" => "marshall.edu",
    "binddn" => "cn=chef-snarf-svc,ou=Service Accounts,ou=Machine Room,dc=marshall,dc=edu",
    "bindpw" => "MDUPmZrhm86btBqZQ2t4",
    "domainzones" => "cn=MicrosoftDNS,dc=DomainDnsZones,dc=marshall,dc=edu"
  },
  "options" => [
    "check-names slave ignore;",
    "multi-master yes;",
    "provide-ixfr yes;",
    "recursive-clients 10000;",
    "request-ixfr yes;",
    "allow-notify { mu-dc; mu-dns; mugc-dc; movc-dc; som-dc; };",
    "allow-query { mu-lan; movc-fw; localhost; };",
    "allow-query-cache { mu-lan; movc-fw; localhost; };",
    "allow-recursion { mu-lan; movc-fw; localhost; };",
    "allow-transfer { mu-dc; mu-dns; som-dc; movc-dc; mugc-dc; rti-dc; };",
    "allow-update-forwarding { any; };",
    "sortlist { 10.101.4/22; };"
  ],
},
"resolver" => {
  "search" => "marshall.edu",
  "nameservers" => [ "10.101.7.30","10.101.4.36","10.101.4.33"],
  "is_dnsserver" => true
}
run_list "recipe[bind]", "recipe[resolver]"
```

## License and Author

Copyright: 2011 Eric G. Wolfe

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
