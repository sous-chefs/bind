bind changelog
==============

v2.2.0
------

* Add `bind_logging_channel` and `bind_logging_category` custom resources.
* Add `bind_view` custom resource.

v2.1.1
------
* According to RFC1035, FQDN length max is 255 characters, and each label (dot delimited) is 63 characters. Setting first column width to 65 characters

v2.1.0
------
* Add support for chrooted install
* Chroot Supported platforms: CentOS/RedHat 6.x+, Debian 8.x+, Ubuntu 14.04 LTS
* Chroot Incompatible platforms: Ubuntu 16.04 LTS [ubuntu/+source/bind9/+bug/1630025](https://bugs.launchpad.net/ubuntu/+source/bind9/+bug/1630025)
* Updated rndc call to be compliant with current auto-configuration standards
* Updated file paths using `::File,join()` method
* Delayed all template creation to avoid file busy conflicts
* Added `.kitchen.dokken.yml` for faster testing with [kitchen-dokken](https://github.com/someara/kitchen-dokken)
* Added support for env var `CHEF_VERSION` to affect kitchen-dokken chef-client version
* Supports chef-client version 12.21.26 and 13.6.4

v2.0.1
------
* Add `manage_serial` option to `bind_primary_zone_template` resource

v2.0.0
------
* Migrate to using custom resources. See MIGRATION.md for details on migrating from v1.x.

v1.3.0
------
* Change default for statistics channel to be false, and add an attribute to set the bind address.

v1.2.0
------
* Add server clause.
  - See [documentation](http://www.zytrax.com/books/dns/ch7/server.html) for reference.
* Add bind forwardzones attribute. 


v1.1.4
------

* restore previous default for querylog size and amount
* correct quoting for log file rotation
* minor rubocop corrections

v1.1.3
------

* Added log_file_size attribute.

v1.1.1
------

* Added array for domainzones attribute

v1.1.0
------

* Add named-checkconf sanity checking
* Add thor/scmversion
* Update specs

v1.0.3
------

* Update documentation

v1.0.2
------

* Stub file for service tests

v1.0.1
------

* Add delayed timing to service reload
* Fix a minor issue with rndc.key on CentOS 6.x

v1.0.0
------

Clearing out backlog of issues.

* Add standalone logging support, to named.options file. #4
* Revert incorrect /etc/named.conf location for EL6.
* Graceful handling for lack of data_bags. #7
* Added documentation for standalone logging support. #8
* Added statistics-channel support. #9
* Updated kitchen and build files.
* Added bats tests.
* Removed minitests/Added chefspec

**BREAKING CHANGE**

* Removed `etc_cookbook_files` and `etc_template_files` in favor of
  simpler `bind['included_files']` attribute

Explanation:

  You could, for examplem, drop off other static files or templates in your sysconf
directory.  Then include these files in your named.conf by overriding this attribute.

v0.2.0
------

This is the first cookbook, I have validated with @fnichol re-write
of [test-kitchen](https://github.com/opscode/test-kitchen).  It took
about 3-4 minutes to validate this cookbook across 4 platforms.

I identified two RHEL 5, and one Ubuntu, recipe bugs which nobody
including myself has caught.  I cannot overstate, how much time this
has saved me.  If you have not tried the test-kitchen re-write,
do yourself the favor and start working with it now.

* Add test-kitchen/Berkshelf skeleton files
* Platform-specific fixes
  - Correct location of `/etc/named.conf` on RHEL 5
  - Added conf_file and options_file are attributes
  - Refactor service actions, and config file rendering
  - Enabled usage of search also on chef-solo via @fabn
  - Various Ubuntu platform fixes via @fabn
  - Added apt recipe to pass test-kitchen

v0.1.1
------

* Pass zone array to template with `uniq` and `sort` 

v0.1.0
------

* Add bind zones attributes for "role (attribute)",
  "ldap", and "databag" sources.

v0.0.9
------

ldap host incorrectly being scoped as node.default

v0.0.8
------

Change node scope to node.default for Chef 11

v0.0.7
------

Update root nameserver D

v0.0.6
------

Move masters keyword to slave block

v0.0.4
------

Clean up and public release

v0.0.2
------

Initial prototype for internal use
