# frozen_string_literal: true
bind_service 'default' do
  action [:create, :start]
end

bind_config 'default'
