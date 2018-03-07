# frozen_string_literal: true
KeyOptions = Struct.new(:name, :algorithm, :secret)

property :algorithm, String
property :bind_config, String, default: 'default'
property :secret, String

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
