unified_mode true

PrimaryZone = Struct.new(:name, :options, :view, :file_name)

property :bind_config, String,
          default: 'default',
          description: 'Name of the bind_config resource to notify actions on'

property :file_name, String,
          name_property: true,
          description: 'Name of the file to store the zone in'

property :options, Array,
          default: [],
          description: 'Array of option strings'

property :view, String,
          description: 'Name of the view to configure the zone in'

property :zone_name, String,
          description: 'The zone name of the zone'

property :source_file, String,
          description: 'File name to source the zonefile from'

action :create do
  create_zone_file
  create_zone_config
end

action :create_if_missing do
  create_zone_file
  create_zone_config
end

action :create_config_only do
  create_zone_config
end

action_class do
  include BindCookbook::ResourceHelpers

  def create_zone_file
    service_resource = find_service_resource

    cookbook_file new_resource.name do
      source new_resource.source_file
      path "#{service_resource.vardir}/primary/db.#{new_resource.name}"
      owner service_resource.run_user
      group service_resource.run_group
      mode '0644'
      action new_resource.action
      notifies :restart, "bind_service[#{service_resource.name}]", :delayed
    end
  end

  def create_zone_config
    new_resource.zone_name ||= new_resource.file_name

    config_template.variables[:primary_zones] << PrimaryZone.new(
      new_resource.zone_name,
      new_resource.options,
      choose_view,
      new_resource.file_name
    )
  end
end
