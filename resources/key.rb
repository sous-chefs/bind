unified_mode true

KeyOptions = Struct.new(:name, :algorithm, :secret)

property :algorithm, String,
          description: 'The algorithm that the secret key was generated from'
property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :secret, String,
          description: 'The secret key'

action :create do
  config_template.variables[:keys] << KeyOptions.new(
    new_resource.name,
    new_resource.algorithm,
    new_resource.secret
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
