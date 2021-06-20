bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_server '10.1.1.1' do
  options [
    'bogus yes',
  ]
end
