bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  additional_config_files %w(additional.conf)
  per_view_additional_config_files %w(additional-view.conf)
end
