# frozen_string_literal: true

ForwardZone = Struct.new(:name, :forwarders, :forward, :view)

property :bind_config, String, default: 'default'
property :forward, String, default: 'only', equal_to: %w(only first)
property :forwarders, Array, default: []
property :view, String

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  new_resource.view = bind_config.default_view unless new_resource.view

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:forward_zones] << ForwardZone.new(
    new_resource.name,
    new_resource.forwarders,
    new_resource.forward,
    new_resource.view
  )
end
