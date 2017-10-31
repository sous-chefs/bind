ServerOptions = Struct.new(:name, :options)

property :options, Array, default: []
property :bind_config, String, default: 'default'

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:servers] << ServerOptions.new(
    new_resource.name,
    new_resource.options
  )
end
