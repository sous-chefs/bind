ForwardZone = Struct.new(:name, :forwarders)

property :bind_config, String, default: 'default'
property :forwarders, Array

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:forward_zones] << ForwardZone.new(
    new_resource.name, new_resource.forwarders
  )
end
