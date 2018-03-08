# frozen_string_literal: true

SecondaryZone = Struct.new(:name, :primaries, :options, :view, :file_name)

property :bind_config, String, default: 'default'
property :options, Array, default: []
property :primaries, Array, required: true
property :view, String

property :file_name, String, name_property: true
property :zone_name, String

action :create do
  new_resource.zone_name = new_resource.file_name unless new_resource.zone_name

  config_template.variables[:secondary_zones] << SecondaryZone.new(
    new_resource.name,
    new_resource.primaries,
    new_resource.options,
    choose_view,
    new_resource.file_name
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
