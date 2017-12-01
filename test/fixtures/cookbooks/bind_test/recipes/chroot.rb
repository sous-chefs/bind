# frozen_string_literal: true
bind_service 'default' do
  chroot true
  action [:create, :start]
end

bind_config 'default' do
  chroot true
end

bind_primary_zone 'example.com'

bind_secondary_zone 'secondary.example.com' do
  primaries ['1.1.1.1', '1.1.1.2']
end

bind_forward_zone 'forward.example.com' do
  forwarders ['1.1.1.1', '1.1.1.2']
end

bind_primary_zone_template 'sub.example.com' do
  records [
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.2.1.1' },
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.1.1.1' },
    { owner: 'www2', type: 'A', ttl: 100, rdata: '10.2.1.1' },
    { owner: 'www2', type: 'A', ttl: 100, rdata: '10.1.1.1' },
    { owner: 'www2', type: 'A', ttl: 100, rdata: '10.4.1.1' },
    { owner: 'www', type: 'A', ttl: 100, rdata: '10.4.1.1' },
    { type: 'MX', rdata: '20 mx2.example.com.' },
    { type: 'MX', rdata: '10 mx1.example.com.' },
    { type: 'NS', rdata: 'ns1.example.com.' },
    { type: 'NS', rdata: 'ns0.example.com.' },
    { type: 'NS', rdata: 'ns3.example.com.' },
    { type: 'A', rdata: '10.0.0.1' },
  ]

  soa serial: '5'
end
