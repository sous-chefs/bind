unified_mode true

View = Struct.new(
  :name,
  :options,
  :match_clients,
  :match_destinations,
  :match_recursive_only
)

property :bind_config, String,
          default: 'default',
          description: 'Name of the `bind_config` resource to notify actions on'
property :match_clients, Array,
          default: [],
          description: 'Serve the content of this view to any client matching an IP address in this list'
property :match_destinations, Array,
          default: [],
          description: 'Serve the content of this view to any request arriving on this IP address'
property :match_recursive_only, [true, false],
          default: false,
          description: 'Match on any recursive requests '
property :options, Array,
          default: [],
          description: 'Array of option strings. Each option should be a valid BIND option minus the trailing semicolon.'

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
