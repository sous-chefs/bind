
bind_service 'default' do
  chroot true
  action [:create, :start]
end

bind_config 'default' do
  chroot true
end
