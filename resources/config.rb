# frozen_string_literal: true

property :chroot, [true, false], default: false
property :chroot_dir, [String, nil], default: lazy { default_property_for(:chroot_dir, chroot) }
property :options_file, String, default: lazy { default_property_for(:options_file, chroot) }
property :conf_file, String, default: lazy { default_property_for(:conf_file, chroot) }
property :bind_service, String, default: 'default'
property :ipv6_listen, [true, false], default: true
property :options, Array, default: []
property :default_view, String, default: 'default'

# The following is deprecated. Use `bind_logging_channel` and
# `bind_logging_category` instead
property :query_log, [String, nil], default: nil
property :query_log_versions, [String, Integer], default: 2
property :query_log_max_size, String, default: '1m'
property :query_log_options, Array, default: []

property :statistics_channel, [Hash, Array]
property :controls, Array, default: []
property :additional_config_files, Array, default: []
property :per_view_additional_config_files, Array, default: []

include BindCookbook::Helpers

# Deprecation: support for adding the query log through the same interface
# as the cusotm resources
LoggingChannel = Struct.new(
  :name, :destination, :severity, :print_category,
  :print_severity, :print_time, :options
)
LoggingCategory = Struct.new(:name, :channels)

action :create do
  bind_service = with_run_context :root do
    find_resource!(:bind_service, new_resource.bind_service)
  end

  Chef::Log.deprecation(
    'Use of the `query_log` property is deprecated in favour of '\
    'using `bind_logging_channel` and `bind_logging_category`'.dup
  ) if new_resource.query_log

  additional_config_files = ['named.options']
  unless new_resource.additional_config_files.empty?
    additional_config_files =
      additional_config_files.push(new_resource.additional_config_files)
  end

  per_view_additional_config_files = ['named.rfc1912.zones']
  unless new_resource.per_view_additional_config_files.empty?
    per_view_additional_config_files =
      per_view_additional_config_files.push(new_resource.per_view_additional_config_files)
  end

  cookbook_file ::File.join(bind_service.sysconfdir, 'named.rfc1912.zones') do
    owner bind_service.run_user
    group bind_service.run_group
    mode '0644'
    action :create
    cookbook 'bind'
  end

  %w(named.empty named.ca named.loopback named.localhost).each do |var_file|
    cookbook_file ::File.join(bind_service.vardir, var_file) do
      owner bind_service.run_user
      group bind_service.run_group
      mode '0644'
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
      only_if { platform_family?('debian') && node['init_package'] == 'init' && new_resource.chroot }
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
      only_if { platform_family?('debian') }
    end

    template '/etc/apparmor.d/local/usr.sbin.named' do
      owner 'root'
      group 'root'
      mode '0644'
      cookbook 'bind'
      source 'chroot_apparmor_profile.erb'
      variables(
        chroot_dir: new_resource.chroot_dir
      )
      only_if { new_resource.chroot && platform?('ubuntu') && node['platform_version'] >= '14.04' }
      notifies :run, 'execute[reload_named_apparmor_profile]', :immediately
    end

    execute 'reload_named_apparmor_profile' do
      command '/sbin/apparmor_parser -r -T -W /etc/apparmor.d/usr.sbin.named'
      action :nothing
      notifies :restart, 'bind_service[default]', :delayed
      only_if { ::File.exist?('/sbin/apparmor_parser') }
    end

    logging_channels = []
    logging_categories = []
    if new_resource.query_log
      destination = "file \"#{query_log}\" versions #{new_resource.query_log_versions} size #{new_resource.query_log_max_size}"
      logging_channels = [LoggingChannel.new(
        'b_query', destination, 'info', nil, nil, true,
        new_resource.query_log_options
      )]
      logging_categories = [LoggingCategory.new('queries', ['b_query'])]
    end

    if new_resource.statistics_channel
      statistics_channel = if new_resource.statistics_channel.is_a?(Array)
                             new_resource.statistics_channel
                           else
                             [].push(new_resource.statistics_channel)
                           end
    end

    template new_resource.options_file do
      owner bind_service.run_user
      group bind_service.run_group
      mode '0644'
      variables(
        vardir: vardir,
        acls: [],
        ipv6_listen: new_resource.ipv6_listen,
        pid_file: default_property_for(:pid_file, new_resource.chroot),
        session_keyfile: default_property_for(:session_keyfile, new_resource.chroot),
        options: new_resource.options,
        statistics_channel: statistics_channel,
        logging_channels: logging_channels,
        logging_categories: logging_categories,
        controls: new_resource.controls
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
      mode '0644'
      variables(
        additional_config_files: additional_config_files.flatten,
        sysconfdir: sysconfdir,
        primary_zones: [],
        secondary_zones: [],
        forward_zones: [],
        linked_zones: [],
        stub_zones: [],
        servers: [],
        keys: [],
        views: [],
        per_view_additional_config_files: per_view_additional_config_files.flatten
      )
      action :nothing
      delayed_action :create
      notifies :restart, 'bind_service[default]', :immediately
      cookbook 'bind'
      source 'named.conf.erb'
    end
  end
end
