# BIND [![Build Status](https://secure.travis-ci.org/joyofhex/cookbook-bind.png?branch=master)](http://travis-ci.org/joyofhex/cookbook-bind)

## Description

A cookbook to manage BIND servers and zones.

## Requirements

This release migrates to using custom resources. Thus we require a more recent
version of chef (12.16 or above). To continue using this cookbook on older
versions please stick with the 1.x versions.

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
`bind\_primary\_zone` resource). The second way is by using the
`bind\_primary\_zone\_template` resource. To use this you need to provide
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

## Specifying per server options

To add the `server` stanza to the configuration use the `bind\_server` resource.

At the moment it only takes an array of options which are placed directly into
the configuration:

```ruby
bind_server '10.0.1.1' do
  options [
    'bogus yes',
    'edns no'
  ]
end
```

This will output the following into the named configuration:

```
server 10.0.1.1 {
  bogus yes;
  edns no;
};
```

## License and Author

Copyright: 2011 Eric G. Wolfe
Copyright: 2017 David Bruce

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
