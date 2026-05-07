# frozen_string_literal: true

include_recipe 'test::disable_resolved'

bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

if platform_family?('debian')
  vardir = '/var/cache/bind'
  run_user = 'bind'
  run_group = 'bind'
else
  vardir = '/var/named'
  run_user = 'named'
  run_group = 'named'
end

# manage file externally
cookbook_file "#{vardir}/primary/db.example.org" do
  source 'example.org'
  owner run_user
  group run_group
end

bind_primary_zone 'example.org' do
  action :create_config_only
end

bind_primary_zone 'example.net' do
  source_file 'custom-example.net'
end
