include_recipe 'bind_test::disable_resolved'

bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  controls ['inet 127.0.0.1 port 953 allow { 127.0.0.1; }']
  statistics_channel address: '127.0.0.1', port: 8080, allow: '127.0.0.1'
  action :create
end

bind_primary_zone 'example.org'

bind_secondary_zone 'secondary.example.org' do
  primaries ['1.1.1.1', '1.1.1.2']
end

bind_forward_zone 'forward.example.org' do
  forwarders ['1.1.1.1', '1.1.1.2']
end

bind_primary_zone_template 'sub.example.org' do
  records [
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.2.1.1' },
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.1.1.1' },
    { owner: 'www2', type: 'A', ttl: 100, rdata: '10.2.1.1' },
    { owner: 'www2', type: 'A', ttl: 100, rdata: '10.1.1.1' },
    { owner: 'www2', type: 'A', ttl: 100, rdata: '10.4.1.1' },
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.4.1.1' },
    { type: 'MX', rdata: '20 mx2.example.org.' },
    { type: 'MX', rdata: '10 mx1.example.org.' },
    { type: 'NS', rdata: 'ns1.example.org.' },
    { type: 'NS', rdata: 'ns0.example.org.' },
    { type: 'NS', rdata: 'ns3.example.org.' },
    { type: 'A', rdata: '10.0.0.1' },
  ]

  soa serial: '5'
end
