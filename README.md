# bind Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/selnux.svg)](https://supermarket.chef.io/cookbooks/bind)
[![CI State](https://github.com/sous-chefs/bind/workflows/ci/badge.svg)](https://github.com/sous-chefs/bind/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

A chef cookbook to manage BIND servers and zones.

## Requirements

This cookbook follows the library pattern. To use the cookbook effectively you'll need a wrapper cookbook that uses the resources provided in this cookbook.

A default recipe is provided. It only provides a basic recursive name server.

### Platforms

- CentOS/RHEL 7+
- Debian 10+
- Ubuntu 18.04+

### Chef

- Chef 15.3+

## Attributes

Most attributes have been removed in favour of custom resources. See the [MIGRATION.md](MIGRATION.md) document.

## Resources

The following resources are provided:

- [bind_acl](documentation/bind_acl.md)
- [bind_config](documentation/bind_config.md)
- [bind_forward_zone](documentation/bind_forward_zone.md)
- [bind_key](documentation/bind_key.md)
- [bind_linked_zone](documentation/bind_linked_zone.md)
- [bind_logging_category](documentation/bind_logging_category.md)
- [bind_logging_channel](documentation/bind_logging_channel.md)
- [bind_primary_zone](documentation/bind_primary_zone.md)
- [bind_primary_zone_template](documentation/bind_primary_zone_template.md)
- [bind_secondary_zone](documentation/bind_secondary_zone.md)
- [bind_server](documentation/bind_server.md)
- [bind_service](documentation/bind_service.md)
- [bind_stub_zone](documentation/bind_stub_zone.md)
- [bind_view](documentation/bind_view.md)

## Usage

Using custom resources leads to a quite flexible configuration, but requires a little bit more work in a wrapper cookbook to use. The following examples are presented here:

- Internal recursive nameserver
- Authoritative primary nameserver
- Authoritative secondary nameserver
- Using views for internal recursion and external authoritative name service

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

There are two ways to create primary zone files with this cookbook. The first is by providing a complete zone file that is placed in the correct directory (and is added to the nameserver configuration by using the `bind_primary_zone` resource). The second way is by using the `bind_primary_zone_template` resource. To use this you need to provide an array of hashes containing the records you want to be added to the zone file.

The following example has both options shown. In a wrapper cookbook add the code below with appropriate modifications.

You'll need to configure the ACL entries (and names) for the example-lan and acl-dns-masters ACLs for your local configuration.

You will also need to arrange for the zone files to be placed in the configured location (which is OS dependent by default).

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
end
```

### Authoritative secondary nameserver

In a wrapper cookbook add the code below with appropriate modifications.

You'll need to configure the ACL entries (and names) for the example-lan and acl-dns-masters ACLs for your local configuration.

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

### Using views for internal recursion and external authoritative name service

Using the `bind_view` resource allows you to configure one or more views in the configuration. When using `bind_view` you will need to tell the zone resources which view they should be configured in. If this is omitted the zone will be configured in the `bind_config` property `default_view` (which defaults to `default`).

```ruby
bind_service 'default'

bind_config 'default' do
  default_view 'external'
end

bind_view 'internal' do
  match_clients ['10.0.0.0/8']
  options [
    'recursion yes'
  ]
end

bind_primary_zone 'internal-example.com' do
  view 'internal'
  zone_name 'example.com'
end

bind_primary_zone 'secret.example.com' do
  view 'internal'
end

bind_view 'external' do
  options [
    'recursion no'
  ]
end

bind_primary_zone 'example.com'
```

### Nameserver in chroot mode

The `bind_service` and `bind_config` resources can accept a boolean `true` or `false` for `chroot`, declaring whether or not to install the BIND server in a chroot manner. If one provider declares this value, the other must match or the converge will fail. Currently all supported platforms except Ubuntu 16.04 LTS are supported with chrooted configuration. By default, this is set to `false`

```ruby
bind_service 'default' do
  chroot true
  action :create
end

bind_config 'default' do
  chroot true
  options [
    'recursion no',
    'allow-transfer { internal-dns; }'
  ]
end
```

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
