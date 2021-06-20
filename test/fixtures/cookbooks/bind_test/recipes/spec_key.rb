bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_key 'secret-key' do
  algorithm 'hmac-sha256'
  secret 'this_is_a_secret_key'
end
