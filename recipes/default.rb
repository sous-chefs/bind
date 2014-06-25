#
# Cookbook Name:: bind
# Recipe:: default
#
# Copyright 2011, Gerald L. Hevener, Jr, M.S.
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
all_zones = []

# Read ACL objects from data bag.
# These will be passed to the named.options template
if Chef::Config['solo'] && !node['bind']['allow_solo_search']
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  begin
    search(:bind, "role:#{node['bind']['acl-role']}") do |acl|
      node.default['bind']['acls'] << acl
    end
  rescue
    Chef::Log.warn('bind databag not found, assuming ACL is empty.')
  end
end

# Install required packages
node['bind']['packages'].each do |bind_pkg|
  package bind_pkg
end

[node['bind']['sysconfdir'], node['bind']['vardir']].each do |named_dir|
  directory named_dir do
    owner node['bind']['user']
    group node['bind']['group']
    mode 00750
  end
end

# Create /var/named subdirectories
%w(data master slaves).each do |subdir|
  directory "#{node['bind']['vardir']}/#{subdir}" do
    owner node['bind']['user']
    group node['bind']['group']
    mode 00770
    recursive true
  end
end

# Copy localhost (rf1912) zones into place
cookbook_file "#{node['bind']['sysconfdir']}/named.rfc1912.zones" do
  owner node['bind']['user']
  group node['bind']['group']
  mode 00644
end

# Copy /var/named files in place
node['bind']['var_cookbook_files'].each do |var_file|
  cookbook_file "#{node['bind']['vardir']}/#{var_file}" do
    owner node['bind']['user']
    group node['bind']['group']
    mode 00644
  end
end

# Create rndc key file, if it does not exist
execute 'rndc-key' do
  command node['bind']['rndc_keygen']
  not_if { ::File.exist?(node['bind']['rndc-key']) }
end

file node['bind']['rndc-key'] do
  owner node['bind']['user']
  group node['bind']['group']
  mode 00600
  action :touch
end

# Include zones from external source if set.
if !node['bind']['zonesource'].nil?
  include_recipe "bind::#{node['bind']['zonesource']}2zone"
else
  Chef::Log.warn('No zonesource defined, assuming zone names are defined as override attributes.')
end

all_zones = node['bind']['zones']['attribute'] + node['bind']['zones']['databag'] + node['bind']['zones']['ldap']

# Render a template with all our global BIND options and ACLs
template node['bind']['options_file'] do
  owner node['bind']['user']
  group node['bind']['group']
  mode 00644
  variables(
    bind_acls: node['bind']['acls']
  )
end

# Render our template with role zones, or returned results from
# zonesource recipe
template node['bind']['conf_file'] do
  owner node['bind']['user']
  group node['bind']['group']
  mode 00644
  variables(
    zones: all_zones.uniq.sort
  )
  notifies :run, 'execute[named-checkconf]', :immediately
  notifies :run, 'execute[failsafe-checkconf]', :immediately
end

# Run named-checkconf as a sanity check on configuration, and start service
execute 'named-checkconf' do
  command "/usr/sbin/named-checkconf -z #{node['bind']['conf_file']}"
  action :nothing
  notifies :enable, 'service[bind]', :immediately
  notifies :start, 'service[bind]', :immediately
  only_if { ::File.exist?('/usr/sbin/named-checkconf') }
end

# Start service if named-checkconf does not exist
execute 'failsafe-checkconf' do
  command 'true'
  action :nothing
  notifies :enable, 'service[bind]', :immediately
  notifies :start, 'service[bind]', :immediately
  not_if { ::File.exist?('/usr/sbin/named-checkconf') }
end

service 'bind' do
  service_name node['bind']['service_name']
  supports reload: true, status: true
  action :nothing
  subscribes :reload, resources("template[#{node['bind']['options_file']}]"), :delayed
  subscribes :reload, resources('execute[named-checkconf]',
                                'execute[failsafe-checkconf]'), :delayed
  only_if { ::File.exist?(node['bind']['options_file']) && ::File.exist?(node['bind']['conf_file']) }
end
