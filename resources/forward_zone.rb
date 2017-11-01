ForwardZone = Struct.new(:name, :forwarders, :forward, :delegation_only)

property :bind_config, String, default: 'default'
property :forwarders, Array, default: []
property :forward, String, default: 'only', equal_to: %w(only first)
property :delegation_only, [true, false], default: false

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:forward_zones] << ForwardZone.new(
    new_resource.name, new_resource.forwarders, new_resource.forward,
    new_resource.delegation_only
  )
end
