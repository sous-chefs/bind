# frozen_string_literal: true

PrimaryZone = Struct.new(:name, :options, :view, :file_name)

property :bind_config, String, default: 'default'
property :options, Array, default: []
property :view, String

property :file_name, String, name_property: true
property :zone_name, String

action :create do
  do_create action
end

action :create_if_missing do
  do_create action
end

action_class do
  include BindCookbook::ResourceHelpers

  def do_create(file_action)
    service_resource = find_service_resource
    new_resource.zone_name = new_resource.file_name unless new_resource.zone_name

    cookbook_file new_resource.name do
      path "#{service_resource.vardir}/primary/db.#{new_resource.name}"
      owner service_resource.run_user
      group service_resource.run_group
      mode 0o440
      action file_action
      notifies :restart, "bind_service[#{service_resource.name}]", :delayed
    end

    config_template.variables[:primary_zones] << PrimaryZone.new(
      new_resource.zone_name,
      new_resource.options,
      choose_view,
      new_resource.file_name
    )
  end
end
