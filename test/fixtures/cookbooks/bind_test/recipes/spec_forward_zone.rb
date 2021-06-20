bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_forward_zone 'example.com'

bind_forward_zone 'example.org' do
  forwarders [
    '10.2.1.1',
    '10.3.2.2',
  ]

  forward 'first'
end
