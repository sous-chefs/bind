# bind Cookbook CHANGELOG

This file is used to list changes made in each version of the bind cookbook.

## 3.3.3 - *2023-03-01*

- Update workflows to 2.0.1
- Remove mdl and replace with markdownlint-cli2

## 3.3.2 - *2023-02-14*

## 3.3.1 - *2022-12-19*

- Fix CI workflow
- Add testing for Alma Linux, Rocky Linux and Ubuntu 22.04
- Formatting fixes

## 3.3.0 - *2021-11-29*

- add `primaries` option to `bind_config`
  - see [the upstream docs](https://bind9.readthedocs.io/en/v9_16_23/reference.html?highlight=primaries#primaries-statement-definition-and-usage)
  - this used the old terminology `master` on platforms that do not have a new enough `named` (9.16.12)

## 3.2.0 - *2021-11-23*

- add `:create_config_only` action to `bind_primary_zone`

## 3.1.0 - *2021-10-20*

- Add source file parameter to `bind_primary_zone`

## 3.0.2 - *2021-10-13*

- Convert `node['platform_version']` to a float for correct comparison

## 3.0.1 - *2021-10-13*

- Include `BindCookbook::Helpers` via `action_class` in `bind_config`
- Add `CHEF_PRODUCT_NAME` variable for setting `product_name`

## 3.0.0 - *2021-10-11*

- Sous Chefs adoption
- Restart `bind_service` immediately when using `delayed_action :create`
- Enable resource `unified_mode` for Chef 17 compatibility
- Add `create_if_missing` to `primary_zone_template`
- Workaround upstream issue as described in <https://bugs.debian.org/983216>
- Update named.ca to latest upstream version
- Cookstyle fixes
- Switch to using an InSpec profile for reusable testing
- Fix issues with chroot on Debian and Ubuntu systems
- Install dnsutils package on Debian-based systems to get dig binary
- Remove sysvinit support
- Fix AppArmor permissions for `bind_logging_channel` when files are used

## 2.3.1 - *2020-01-23*

- #58: Multiple statistices channel support - bmhughes
- #59: fix bug in additional config files directive - ramereth

## 2.3.0 - *2019-10-21*

- Update supported OS and Chef clients.
- Support chroot on ubuntu 18.
- Add `bind_stub_zone` resource.
- Add `controls`, `per_view_additional_config`, and `additional_config_files` to `bind_config` resource.

## 2.2.1 - *2018-10-08*

- Add support for in-view directive using  `bind_linked_zone` resource.

## 2.2.0 - *2018-03-08*

- Add `bind_logging_channel` and `bind_logging_category` custom resources.
- Add `bind_view` custom resource.
- Add `:create_if_missing` action to `bind_primary_zone` resource.

## 2.1.1 - *2017-12-01*

- According to RFC1035, FQDN length max is 255 characters, and each label (dot delimited) is 63 characters. Setting first column width to 65 characters

## 2.1.0 - *2017-12-01*

- Add support for chrooted install
- Chroot Supported platforms: CentOS/RedHat 6.x+, Debian 8.x+, Ubuntu 14.04 LTS
- Chroot Incompatible platforms: Ubuntu 16.04 LTS [ubuntu/+source/bind9/+bug/1630025](https://bugs.launchpad.net/ubuntu/+source/bind9/+bug/1630025)
- Updated rndc call to be compliant with current auto-configuration standards
- Updated file paths using `::File,join()` method
- Delayed all template creation to avoid file busy conflicts
- Added `.kitchen.dokken.yml` for faster testing with [kitchen-dokken](https://github.com/someara/kitchen-dokken)
- Added support for env var `CHEF_VERSION` to affect kitchen-dokken chef-client version
- Supports chef-client version 12.21.26 and 13.6.4

## 2.0.1 - *2017-11-17*

- Add `manage_serial` option to `bind_primary_zone_template` resource

## 2.0.0 - *2017-11-07*

- Migrate to using custom resources. See MIGRATION.md for details on migrating from v1.x.

## 1.3.0 - *2017-04-17*

- Change default for statistics channel to be false, and add an attribute to set the bind address.

## 1.2.0 - *2015-01-02*

- Add server clause.
  - See [documentation](http://www.zytrax.com/books/dns/ch7/server.html) for reference.
- Add bind forwardzones attribute.

## 1.1.4 - *2014-11-19*

- Restore previous default for querylog size and amount
- Correct quoting for log file rotation
- Minor rubocop corrections

## 1.1.3 - *2014-10-08*

- Added `log_file_size` attribute.

## 1.1.1 - *2014-08-13*

- Added array for `domainzones` attribute

## 1.1.0 - *2014-05-25*

- Add named-checkconf sanity checking
- Add thor/scmversion
- Update specs

## 1.0.3 - *2014-03-17*

- Update documentation

## 1.0.2 - *2014-02-18*

- Stub file for service tests

## 1.0.1 - *2014-02-16*

- Add delayed timing to service reload
- Fix a minor issue with `rndc.key` on CentOS 6.x

## 1.0.0 - *2014-02-13*

Clearing out backlog of issues.

- Add standalone logging support, to `named.options` file. #4
- Revert incorrect `/etc/named.conf` location for EL6.
- Graceful handling for lack of data_bags. #7
- Added documentation for standalone logging support. #8
- Added statistics-channel support. #9
- Updated kitchen and build files.
- Added bats tests.
- Removed minitests/Added chefspec

### BREAKING CHANGE

- Removed `etc_cookbook_files` and `etc_template_files` in favor of simpler `bind['included_files']` attribute

Explanation:

You could, for examplem, drop off other static files or templates in your sysconf directory.  Then include these files in your named.conf by overriding this attribute.

## 0.2.0 - *2013-05-30*

This is the first cookbook, I have validated with @fnichol re-write of [test-kitchen](https://github.com/opscode/test-kitchen).  It took about 3-4 minutes to validate this cookbook across 4 platforms.

I identified two RHEL 5, and one Ubuntu, recipe bugs which nobody including myself has caught.  I cannot overstate, how much time this has saved me.  If you have not tried the test-kitchen re-write, do yourself the favor and start working with it now.

- Add test-kitchen/Berkshelf skeleton files
- Platform-specific fixes
  - Correct location of `/etc/named.conf` on RHEL 5
  - Added `conf_file` and `options_file` are attributes
  - Refactor service actions, and config file rendering
  - Enabled usage of search also on chef-solo via @fabn
  - Various Ubuntu platform fixes via @fabn
  - Added apt recipe to pass test-kitchen

## 0.1.1 - *2013-04-15*

- Pass zone array to template with `uniq` and `sort`

## 0.1.0 - *2013-03-26*

- Add bind zones attributes for "role (attribute)", "ldap", and "databag" sources.

## 0.0.9 - *2013-03-25*

- ldap host incorrectly being scoped as `node.default`

## 0.0.8 - *2013-03-25*

- Change node scope to `node.default` for Chef 11

## 0.0.7 - *2013-01-24*

- Update root nameserver D

## 0.0.6 - *2012-08-01*

- Move masters keyword to slave block

## 0.0.4 - *2012-01-05*

- Clean up and public release

## 0.0.2 - *2011-04-22*

- Initial prototype for internal use
