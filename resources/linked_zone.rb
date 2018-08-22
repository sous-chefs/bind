# frozen_string_literal: true

LinkedZone = Struct.new(:name, :in_view, :view)

property :bind_config, String, default: 'default'
property :in_view, String
property :view, String
property :zone_name, String

action :create do
  new_resource.zone_name = new_resource.name unless new_resource.zone_name
  config_template.variables[:linked_zones] << LinkedZone.new(
    new_resource.zone_name,
    new_resource.in_view,
    choose_view
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
