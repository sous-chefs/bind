property :options_file, String, default: lazy { default_property_for(:options_file) }
property :conf_file, String, default: lazy { default_property_for(:conf_file) }
property :bind_service, String, default: 'default'

include BindCookbook::Helpers

action :create do
  bind_service = with_run_context :root do
    find_resource!(:bind_service, new_resource.bind_service)
  end

  cookbook_file "#{bind_service.sysconfdir}/named.rfc1912.zones" do
    owner bind_service.run_user
    group bind_service.run_group
    mode 0o0644
    action :create
    cookbook 'bind'
  end

  %w(named.empty named.ca named.loopback named.localhost).each do |var_file|
    cookbook_file "#{bind_service.vardir}/#{var_file}" do
      owner bind_service.run_user
      group bind_service.run_group
      mode 0o0644
      action :create
      cookbook 'bind'
    end
  end

  execute 'generate_rndc_key' do
    command "rndc-confgen -a -r /dev/urandom; chown #{bind_service.run_user}:#{bind_service.run_group} #{default_property_for(:rndc_key_file)}"
    creates default_property_for(:rndc_key_file)
  end

  file '/etc/rndc.key' do
    owner bind_service.run_user
    group bind_service.run_group
    mode 0o0600
    action :create_if_missing
  end

  template new_resource.options_file do
    owner bind_service.run_user
    group bind_service.run_group
    mode 0o644
    variables(
      bind_acls: []
    )
    cookbook 'bind'
  end

  with_run_context :root do
    template new_resource.conf_file do
      owner bind_service.run_user
      group bind_service.run_group
      mode 0o644
      variables(
        primary_zones: [],
        secondary_zones: [],
        forward_zones: []
      )
      action :nothing
      delayed_action :create
      notifies :restart, 'bind_service[default]', :immediately
      cookbook 'bind'
    end
  end
end
