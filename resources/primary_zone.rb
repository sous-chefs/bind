PrimaryZone = Struct.new(:name, :type)

property :bind_config, String, default: 'default'

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_service = with_run_context :root do
    find_resource!(:bind_service, bind_config.bind_service)
  end

  cookbook_file new_resource.name do
    path "#{bind_service.vardir}/primary/db.#{new_resource.name}"
    owner bind_service.run_user
    group bind_service.run_group
    mode 0o440
    action :create
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:primary_zones] << PrimaryZone.new(
    new_resource.name
  )
end
