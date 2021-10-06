include_recipe 'bind_test::disable_resolved'

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

bind_primary_zone_template 'example.net' do
  soa serial: 100, minimum: 3600
  records [
    { type: 'NS', rdata: 'ns1.example.net.' },
    { owner: 'ns1', type: 'A', rdata: '1.1.1.1' },
  ]
end

bind_view 'external' do
  options [
    'recursion no',
  ]
end

bind_linked_zone 'example.net' do
  in_view 'internal'
  view 'external'
end
