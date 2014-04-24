#
# Cookbook Name:: bind
# Attributes:: default
#
# Copyright 2011, Eric G. Wolfe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['bind']['packages'] = %w(bind bind-utils bind-libs)
default['bind']['vardir'] = '/var/named'
default['bind']['sysconfdir'] = '/etc/named'
default['bind']['conf_file'] = '/etc/named.conf'
default['bind']['options_file'] = "#{node['bind']['sysconfdir']}/named.options"
default['bind']['service_name'] = 'named'
default['bind']['user'] = 'named'
default['bind']['group'] = 'named'
default['bind']['rndc-key'] = '/etc/rndc.key'

# Allow usage with chef-solo-search, see https://github.com/edelight/chef-solo-search
default['bind']['allow_solo_search'] = false

# Set platform/version specific directories and settings
case node['platform_family']
when 'debian'
  default['bind']['packages'] = %w(bind9 bind9utils)
  default['bind']['sysconfdir'] = '/etc/bind'
  default['bind']['conf_file'] = "#{node['bind']['sysconfdir']}/named.conf"
  default['bind']['options_file'] = "#{node['bind']['sysconfdir']}/named.options"
  default['bind']['vardir'] = '/var/cache/bind'
  default['bind']['service_name'] = 'bind9'
  default['bind']['user'] = 'bind'
  default['bind']['group'] = 'bind'
  default['bind']['rndc-key'] = "#{node['bind']['sysconfdir']}/rndc.key"
end

# Files which should be included in named.conf
default['bind']['included_files'] = %w(named.rfc1912.zones named.options)

# These are var files referenced by our rfc1912 zone and root hints (named.ca) zone
default['bind']['var_cookbook_files'] = %w(named.empty named.ca named.loopback named.localhost)

# This an array of masters, or servers which you transfer from.
default['bind']['masters'] = []

# Boolean to turn off/on IPV6 support
default['bind']['ipv6_listen'] = false

# If this is a virtual machine, you need to use urandom as
# any VM does not have a real CMOS clock for entropy.
if node.key?('virtualization') && node['virtualization']['role'] == 'guest'
  default['bind']['rndc_keygen'] = 'rndc-confgen -a -r /dev/urandom'
else
  default['bind']['rndc_keygen'] = 'rndc-confgen -a'
end

# These two attributes are used to load named ACLs from data bags.
# The search key is the "acl-role", and defaults to internal-acl
default['bind']['acl-role'] = 'internal-acl'
default['bind']['acls'] = []

# This attribute is for setting site-specific Global option lines
# to be included in the template.
default['bind']['options'] = []

# Set an override at the role, or environment level for the bind.zones array.
# bind.zonetype is used in the named.conf file for configured zones.
default['bind']['zones']['attribute'] = []
default['bind']['zones']['ldap'] = []
default['bind']['zones']['databag'] = []
default['bind']['zonetype'] = 'slave'
default['bind']['zonesource'] = nil

# This attribute enable logging
default['bind']['enable_log'] = false
default['bind']['log_file_versions'] = 10
default['bind']['log_file_size'] = '500m'
default['bind']['log_file'] = '/var/log/bind9/query.log'
default['bind']['log_options'] = []

# These are for enabling statistics-channel on a TCP port.
default['bind']['statistics-channel'] = true
default['bind']['statistics-port'] = 8080

case node['platform_family']
when 'rhel'
  default['bind']['statistics-channel'] if node['platform_version'].to_i <= 5
end
