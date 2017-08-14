SecondaryZone = Struct.new(:name, :primaries)

property :bind_config, String, default: 'default'
property :primaries, Array

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:secondary_zones] << SecondaryZone.new(
    new_resource.name, new_resource.primaries
  )
end
