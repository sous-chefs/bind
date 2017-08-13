
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  action :create
end

bind_primary_zone 'example.com'

bind_secondary_zone 'secondary.example.com' do
  primaries ['1.1.1.1', '1.1.1.2']
end

bind_forward_zone 'forward.example.com' do
  forwarders ['1.1.1.1', '1.1.1.2']
end
