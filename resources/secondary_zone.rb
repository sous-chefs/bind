# frozen_string_literal: true
SecondaryZone = Struct.new(:name, :primaries, :options, :type)

property :bind_config, String, default: 'default'
property :options, Array, default: []
property :primaries, Array, required: true

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  slave_config_template = with_run_context :root do
    find_resource!(:template, bind_config.secondary_zones)
  end

  slave_config_template.variables[:zones] << SecondaryZone.new(
    new_resource.name, new_resource.primaries, new_resource.options, 'slave'
  )
end
