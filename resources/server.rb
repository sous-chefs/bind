unified_mode true

ServerOptions = Struct.new(:name, :options)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :options, Array,
          default: [],
          description: 'Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.'

action :create do
  config_template.variables[:servers] << ServerOptions.new(
    new_resource.name,
    new_resource.options
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
