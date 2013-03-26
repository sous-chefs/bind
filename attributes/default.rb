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

default['bind']['packages'] = %w{ bind bind-utils bind-libs }
default['bind']['vardir'] = "/var/named"
default['bind']['sysconfdir'] = "/etc/named"

# Set platform/version specific directories
case node['platform']
  when "redhat","centos","scientific","amazon","oracle"
    default['bind']['packages'] = %w{ bind bind-utils bind-libs }
    default['bind']['vardir'] = "/var/named"
    default['bind']['sysconfdir'] = "/etc/named"
  when "debian","ubuntu"
    default['bind']['packages'] = %w{ bind9 bind9utils }
    default['bind']['sysconfdir'] = "/etc/bind"
    default['bind']['vardir'] = "/var/cache/bind"
end

# Will loop through these and pull them as cookbook_files
default['bind']['etc_cookbook_files'] = %w{ named.rfc1912.zones }

# These are template files.  No looping through them, but they need included in named.conf
default['bind']['etc_template_files'] = %w{ named.options }

# These are var files referenced by our rfc1912 zone and root hints (named.ca) zone
default['bind']['var_cookbook_files'] = %w{ named.empty named.ca named.loopback named.localhost }

# This an array of masters, or servers which you transfer from.
default['bind']['masters'] = Array.new

# Boolean to turn off/on IPV6 support
default['bind']['ipv6_listen'] = false

# If this is a virtual machine, you need to use urandom as
# any VM does not have a real CMOS clock for entropy.
if node.has_key?('virtualization') and node['virtualization']['role'] == "guest"
  default['bind']['rndc_keygen'] = "rndc-confgen -a -r /dev/urandom"
else
  default['bind']['rndc_keygen'] = "rndc-confgen -a"
end

# These two attributes are used to load named ACLs from data bags.
# The search key is the "acl-role", and defaults to internal-acl
default['bind']['acl-role'] = "internal-acl"
default['bind']['acls'] = Array.new

# This attribute is for setting site-specific Global option lines
# to be included in the template.
default['bind']['options'] = Array.new

# Set an override at the role, or environment level for the bind.zones array.
# bind.zonetype is used in the named.conf file for configured zones.
default['bind']['zones']['attribute'] = Array.new
default['bind']['zones']['ldap'] = Array.new
default['bind']['zones']['databag'] = Array.new
default['bind']['zonetype'] = "slave"
default['bind']['zonesource'] = nil
