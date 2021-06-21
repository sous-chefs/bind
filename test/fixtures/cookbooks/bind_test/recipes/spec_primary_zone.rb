bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_primary_zone 'example.com'

bind_primary_zone 'example.org' do
  options [
    'allow-transfer { none; }',
  ]
end

bind_primary_zone 'example.net' do
  action :create_if_missing
end
