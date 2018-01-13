# frozen_string_literal: true

PrimaryZone = Struct.new(:name, :options, :view)

property :bind_config, String, default: 'default'
property :options, Array, default: []
property :view, String

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  new_resource.view = bind_config.default_view unless new_resource.view

  bind_service = with_run_context :root do
    find_resource!(:bind_service, bind_config.bind_service)
  end

  cookbook_file new_resource.name do
    path "#{bind_service.vardir}/primary/db.#{new_resource.name}"
    owner bind_service.run_user
    group bind_service.run_group
    mode 0o440
    action :create
    notifies :restart, "bind_service[#{bind_service.name}]", :delayed
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:primary_zones] << PrimaryZone.new(
    new_resource.name, new_resource.options, new_resource.view
  )
end
