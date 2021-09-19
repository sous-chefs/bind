unified_mode true

LinkedZone = Struct.new(:name, :in_view, :view)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :in_view, String,
          description: 'The view of the zone to reference'
property :view, String,
          description: 'Name of the view to configure the zone in'
property :zone_name, String,
          description: 'The name of the zone'

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
