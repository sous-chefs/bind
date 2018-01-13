# frozen_string_literal: true
View = Struct.new(:name, :options)

property :bind_config, String, default: 'default'
property :options, Array, default: []

property :match_clients, Array, default: []
property :match_destinations, Array, default: []
property :match_recursive_only, [true, false], default: false

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:views] << View.new(
    new_resource.name, new_resource.options
  )
end
