
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_view 'default' do
  match_clients ['10.0.0.0/8', '192.168.0.0/16']
  match_destinations ['172.16.0.0/16']
  match_recursive_only true
  options [
    'recursion no',
  ]
end

bind_primary_zone 'example.com'

bind_primary_zone 'example.org' do
  options [
    'allow-transfer { none; }',
  ]
end
