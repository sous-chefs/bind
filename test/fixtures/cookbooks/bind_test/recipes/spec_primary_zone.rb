bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_primary_zone 'example.org' do
  options [
    'allow-transfer { none; }',
  ]
end

bind_primary_zone 'example.com' do
  source_file 'custom-example.com'
end

bind_primary_zone 'example.net' do
  action :create_if_missing
end

bind_primary_zone 'example.only' do
  action :create_config_only
end
