# frozen_string_literal: true
property :chroot, [true, false], default: false
property :chroot_dir, [String, nil], default: lazy { default_property_for(:chroot_dir, chroot) }
property :options_file, String, default: lazy { default_property_for(:options_file, chroot) }
property :conf_file, String, default: lazy { default_property_for(:conf_file, chroot) }
property :bind_service, String, default: 'default'
property :ipv6_listen, [true, false], default: true
property :options, Array, default: []
property :default_view, String, default: 'default'

property :query_log, [String, nil], default: nil
property :query_log_versions, [String, Integer], default: 2
property :query_log_max_size, String, default: '1m'
property :query_log_options, Array, default: []

property :statistics_channel, Hash

include BindCookbook::Helpers

action :create do
  bind_service = with_run_context :root do
    find_resource!(:bind_service, new_resource.bind_service)
  end

  additional_config_files = ['named.options']
  per_view_additional_config_files = ['named.rfc1912.zones']

  cookbook_file ::File.join(bind_service.sysconfdir, 'named.rfc1912.zones') do
    owner bind_service.run_user
    group bind_service.run_group
    mode 0o0644
    action :create
    cookbook 'bind'
  end

  %w(named.empty named.ca named.loopback named.localhost).each do |var_file|
    cookbook_file ::File.join(bind_service.vardir, var_file) do
      owner bind_service.run_user
      group bind_service.run_group
      mode 0o0644
      action :create
      cookbook 'bind'
    end
  end

  rndc_cmd = 'rndc-confgen -a -r /dev/urandom -u ' + bind_service.run_user
  rndc_cmd.concat(" -t #{new_resource.chroot_dir}") if new_resource.chroot

  execute 'generate_rndc_key' do
    command rndc_cmd
    creates default_property_for(:rndc_key_file, new_resource.chroot)
  end

  with_run_context :root do
    if new_resource.chroot
      vardir     = bind_service.vardir.gsub(new_resource.chroot_dir, '')
      query_log  = new_resource.query_log.nil? ? new_resource.query_log : new_resource.query_log.gsub(new_resource.chroot_dir, '')
      sysconfdir = bind_service.sysconfdir.gsub(new_resource.chroot_dir, '')
    else
      vardir     = bind_service.vardir
      query_log  = new_resource.query_log
      sysconfdir = bind_service.sysconfdir
    end

    template '/etc/init.d/bind9' do
      owner 'root'
      group 'root'
      mode '0755'
      variables(
        chroot: new_resource.chroot_dir
      )
      action :nothing
      delayed_action :create
      notifies :restart, 'bind_service[default]', :delayed
      cookbook 'bind'
      source 'init.bind9.erb'
      only_if { node['platform_family'] == 'debian' && node['init_package'] == 'init' && new_resource.chroot }
    end

    template '/etc/default/bind9' do
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        chroot: new_resource.chroot_dir,
        ipv6: new_resource.ipv6_listen,
        user: bind_service.run_user
      )
      action :nothing
      delayed_action :create
      notifies :restart, 'bind_service[default]', :delayed
      cookbook 'bind'
      source 'default.bind9.erb'
      only_if { node['platform_family'] == 'debian' }
    end

    template new_resource.options_file do
      owner bind_service.run_user
      group bind_service.run_group
      mode '0644'
      variables(
        vardir: vardir,
        acls: [],
        ipv6_listen: new_resource.ipv6_listen,
        options: new_resource.options,
        query_log: query_log,
        query_log_versions: new_resource.query_log_versions,
        query_log_max_size: new_resource.query_log_max_size,
        query_log_options: new_resource.query_log_options,
        statistics_channel: new_resource.statistics_channel
      )
      action :nothing
      delayed_action :create
      notifies :restart, 'bind_service[default]', :delayed
      cookbook 'bind'
      source 'named.options.erb'
    end

    template new_resource.conf_file do
      owner bind_service.run_user
      group bind_service.run_group
      mode 0o644
      variables(
        additional_config_files: additional_config_files,
        sysconfdir: sysconfdir,
        primary_zones: [],
        secondary_zones: [],
        forward_zones: [],
        servers: [],
        keys: [],
        views: [],
        per_view_additional_config_files: per_view_additional_config_files
      )
      action :nothing
      delayed_action :create
      notifies :restart, 'bind_service[default]', :delayed
      cookbook 'bind'
      source 'named.conf.erb'
    end
  end
end
