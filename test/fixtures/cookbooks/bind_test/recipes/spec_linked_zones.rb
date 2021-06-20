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

bind_primary_zone 'sub.example.com'

bind_view 'external' do
  options [
    'recursion no',
  ]
end

bind_linked_zone 'subdomain' do
  zone_name 'sub.example.com'
  in_view 'internal'
  view 'external'
end
