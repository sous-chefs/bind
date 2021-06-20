bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_primary_zone_template 'empty.example.com' do
  options [
    'check-names warn',
  ]
end

# This example has all the different possibilities overridden and tested.
bind_primary_zone_template 'custom.example.com' do
  soa serial: 100, mname: 'ns1.example.com.',
      rname: 'hostmaster.example.com.',
      refresh: '1d', retry: '1h', expire: '4w',
      minimum: 10

  default_ttl 200

  records [
    { type: 'NS', rdata: 'ns1.example.com.' },
    { type: 'NS', rdata: 'ns2.example.com.' },
    { type: 'MX', rdata: '10 mx1.example.com.' },
    { type: 'MX', rdata: '20 mx1.example.com.' },
    { owner: 'www', type: 'A', ttl: 20, rdata: '10.5.0.1' },
  ]
end
