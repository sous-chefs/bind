# frozen_string_literal: true
ServerOptions = Struct.new(:name, :options)

property :bind_config, String, default: 'default'
property :options, Array, default: []

action :create do
  config_template.variables[:servers] << ServerOptions.new(
    new_resource.name,
    new_resource.options
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
