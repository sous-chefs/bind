bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  default_view 'internal'
end

bind_view 'internal' do
  match_clients ['10.0.0.0/8']
  options [
    'recursion yes',
  ]
end

bind_primary_zone 'internal.example.com'

bind_primary_zone_template 'internal-example.com' do
  view 'internal'
  zone_name 'example.com'
  records []
end

bind_view 'external' do
  options [
    'recursion no',
  ]
end

bind_primary_zone 'external-example.com' do
  view 'external'
  zone_name 'example.com'
end
