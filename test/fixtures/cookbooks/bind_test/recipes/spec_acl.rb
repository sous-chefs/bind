bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_acl 'internal' do
  entries [
    '10.0.0.0/24',
    'localhost',
    'localnets',
  ]
end

bind_acl 'external' do
  entries ['any']
end

bind_acl 'external-private-interfaces' do
  entries [
    '192.0.2.15',
    '192.0.2.16',
    '192.0.2.17',
  ]
end
