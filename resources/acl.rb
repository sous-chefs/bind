unified_mode true

ACL = Struct.new(:name, :entries)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'
property :entries, Array,
          description: 'An array of strings representing each acl entry'

action :create do
  options_template.variables[:acls] << ACL.new(
    new_resource.name,
    new_resource.entries
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
