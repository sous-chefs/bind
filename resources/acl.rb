ACL = Struct.new(:name, :entries)

property :bind_config, String, default: 'default'

property :entries, Array

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  options_template = with_run_context :root do
    find_resource!(:template, bind_config.options_file)
  end

  options_template.variables[:acls] << ACL.new(
    new_resource.name,
    new_resource.entries
  )
end
