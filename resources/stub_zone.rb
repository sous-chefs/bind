unified_mode true

StubZone = Struct.new(:name, :primaries, :options, :view, :file_name)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :file_name, String,
          name_property: true,
          description: 'Name of the file to store the zone in'
property :options, Array,
          default: [],
          description: 'Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.'
property :primaries, Array,
          required: true,
          description: 'An array of IP addresses used as the upstream master for this zone'
property :view, String,
          description: 'Name of the view to configure the zone in'
property :zone_name, String,
          description: 'The zone name of the zone'

action :create do
  new_resource.zone_name = new_resource.file_name unless new_resource.zone_name

  config_template.variables[:stub_zones] << StubZone.new(
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
