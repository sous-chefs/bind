[Back to resource list](../README.md#resources)

# bind_acl

This resource allows you to create a named ACL list within the BIND configuration.

## Actions

| Action    | Description             |
| --------- | ----------------------- |
| `:create` | Creates a BIND ACL list |

## Properties

| Name          | Type   | Default   | Description                                              |
| ------------- | ------ | --------- | -------------------------------------------------------- |
| `bind_config` | String | `default` | Name of the `bind_config` resource to notify actions on  |
| `entries`     | Array  | `[]`      | An array of strings representing each acl entry          |

### entries

Each entry should be a valid BIND address match list. This means it can be:

- an IP address
- an IP prefix
- a key id
- the name of a different address march list from another acl statement
- a nested address match list enclosed in braces

Predefined ACLs (from BIND itself) which do not need additional configuration are: any, none, localhost, and localnets.

## Examples

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
