unified_mode true

ForwardZone = Struct.new(:name, :forwarders, :forward, :view)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :forward, String,
          default: 'only',
          equal_to: %w(only first),
          description: 'Set to "first" if you wish to try a regular lookup if forwaridng fails. "only" will cause the query to fail if forwarding fails.'
property :forwarders, Array,
          default: [],
          description: 'An array of IP addresses to which requests for this zone will be forwarded to'
property :view, String,
          description: 'Name of the view to configure the zone in'

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
