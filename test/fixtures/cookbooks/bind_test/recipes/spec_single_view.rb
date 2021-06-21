bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  default_view 'internal'
end

bind_view 'internal'

bind_primary_zone 'example.com'

bind_secondary_zone 'example.org' do
  view 'internal'
  primaries ['10.0.1.1']
end

bind_forward_zone 'example.net' do
  forwarders ['10.1.1.1']
end
