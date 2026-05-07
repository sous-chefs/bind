# frozen_string_literal: true

service 'systemd-resolved' do
  action [:disable, :stop]
end
