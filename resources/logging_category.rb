unified_mode true

LoggingCategory = Struct.new(:name, :channels)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :category, String,
          name_property: true,
          equal_to: %w(
            client cname config database default delegation-only dispatch dnssec edns-disabled general lame-servers
            network notify queries query-errors rate-limit resolver rpz security spill unmatched update update-security
            xfer-in xfer-out
          ),
          description: 'Name of the BIND logging category to send to the specified channels'
property :channels, [Array, String],
          required: true,
          coerce: proc { |m| m.is_a?(String) ? [m] : m },
          description: 'Array of names (or single name) of channels to send the category of logs to'

action :create do
  options_template.variables[:logging_categories] << LoggingCategory.new(new_resource.category, new_resource.channels)
end

action_class do
  include BindCookbook::ResourceHelpers
end
