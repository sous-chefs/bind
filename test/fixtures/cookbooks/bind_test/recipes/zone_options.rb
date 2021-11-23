include_recipe 'bind_test::disable_resolved'

bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

::Chef::DSL::Recipe.include BindCookbook::Helpers
::Chef::Resource.include BindCookbook::Helpers

# manage file externally
cookbook_file "#{default_property_for(:vardir, false)}/primary/db.example.org" do
  source 'example.org'
  owner default_property_for(:run_user, false)
  group default_property_for(:run_group, false)
end

bind_primary_zone 'example.org' do
  action :create_config_only
end

bind_primary_zone 'example.net' do
  source_file 'custom-example.net'
end
