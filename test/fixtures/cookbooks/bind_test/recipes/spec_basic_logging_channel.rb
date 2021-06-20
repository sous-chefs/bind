
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'

bind_logging_channel 'syslog' do
  destination 'syslog'
  facility 'mail'
  severity 'info'
  print_category true
  print_severity true
  print_time true
end

bind_logging_channel 'stderr' do
  destination 'stderr'
end

bind_logging_channel 'example-file' do
  destination 'file'
  path 'test.log'
  versions 10
  size 'unlimited'
end

bind_logging_channel 'basic-file' do
  destination 'file'
  path 'basic.log'
end

bind_logging_category 'default' do
  channels %w(syslog stderr)
end

bind_logging_category 'client' do
  channels 'example-file'
end
