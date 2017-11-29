# frozen_string_literal: true
KeyOptions = Struct.new(:name, :algorithm, :secret)

property :algorithm, String
property :bind_config, String, default: 'default'
property :secret, String

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:keys] << KeyOptions.new(
    new_resource.name,
    new_resource.algorithm,
    new_resource.secret
  )
end
