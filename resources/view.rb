# frozen_string_literal: true

View = Struct.new(
  :name,
  :options,
  :match_clients,
  :match_destinations,
  :match_recursive_only
)

property :bind_config, String, default: 'default'
property :options, Array, default: []

property :match_clients, Array, default: []
property :match_destinations, Array, default: []
property :match_recursive_only, [true, false], default: false

action :create do
  config_template.variables[:views] << View.new(
    new_resource.name,
    new_resource.options,
    new_resource.match_clients,
    new_resource.match_destinations,
    new_resource.match_recursive_only
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
