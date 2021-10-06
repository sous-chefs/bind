include_recipe 'bind_test::disable_resolved'

bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  default_view 'internal'
  statistics_channel [
    { address: '127.0.0.1', port: 8080, allow: '127.0.0.1' },
    { address: '127.0.0.1', port: 8081 },
  ]
end

bind_view 'internal' do
  match_clients ['127.0.0.0/8']
  options ['recursion yes']
end

bind_primary_zone 'example.org'

bind_secondary_zone 'secondary.example.org' do
  primaries ['1.1.1.1', '1.1.1.2']
end

bind_forward_zone 'forward.example.org' do
  forwarders ['1.1.1.1', '1.1.1.2']
end

bind_primary_zone_template 'internal-sub.example.org' do
  zone_name 'sub.example.org'
  records [
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.2.1.1' },
    { type: 'MX', rdata: '20 mx2.example.org.' },
    { type: 'MX', rdata: '10 mx1.example.org.' },
    { type: 'NS', rdata: 'ns1.example.org.' },
    { type: 'NS', rdata: 'ns0.example.org.' },
    { type: 'NS', rdata: 'ns3.example.org.' },
    { type: 'A', rdata: '10.0.0.1' },
    { type: 'TXT', rdata: 'internal' },
  ]

  soa serial: '5'
end

bind_view 'external' do
  options ['recursion no']
end

bind_primary_zone_template 'external-sub.example.org' do
  view 'external'
  zone_name 'sub.example.org'
  records [
    { owner: 'www', type: 'A', ttl: 100, rdata: '192.168.1.1' },
    { type: 'MX', rdata: '20 mx2.example.org.' },
    { type: 'MX', rdata: '10 mx1.example.org.' },
    { type: 'NS', rdata: 'ns1.example.org.' },
    { type: 'NS', rdata: 'ns0.example.org.' },
    { type: 'NS', rdata: 'ns3.example.org.' },
    { type: 'A', rdata: '192.168.1.2' },
    { type: 'TXT', rdata: 'external' },
  ]

  soa serial: '10'
end
