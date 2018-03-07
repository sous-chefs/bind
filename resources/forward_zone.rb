# frozen_string_literal: true

ForwardZone = Struct.new(:name, :forwarders, :forward, :view)

property :bind_config, String, default: 'default'
property :forward, String, default: 'only', equal_to: %w(only first)
property :forwarders, Array, default: []
property :view, String

action :create do
  config_template.variables[:forward_zones] << ForwardZone.new(
    new_resource.name,
    new_resource.forwarders,
    new_resource.forward,
    choose_view
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
