# frozen_string_literal: true
ACL = Struct.new(:name, :entries)

property :bind_config, String, default: 'default'

property :entries, Array

action :create do
  options_template.variables[:acls] << ACL.new(
    new_resource.name,
    new_resource.entries
  )
end

action_class do
  include BindCookbook::ResourceHelpers
end
