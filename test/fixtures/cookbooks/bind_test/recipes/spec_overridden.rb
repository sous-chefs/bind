bind_service 'default' do
  sysconfdir '/test/etc'
  vardir '/test/var'
  run_user 'bind'
  run_group 'bind'
  action [:create, :start]
end

bind_config 'default' do
  ipv6_listen false
  primaries({ 'test' => %w(1.2.3.4 5.6.7.8 9.10.11.12) })
  options_file '/etc/bind/bind.options'
  conf_file '/etc/bind/bind.conf'
  options [
    'notify no',
    'recursion yes',
  ]
end
