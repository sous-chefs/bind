# frozen_string_literal: true

execute 'mask_systemd_resolved' do
  command 'systemctl mask --now systemd-resolved.service systemd-resolved.socket'
  not_if 'systemctl is-enabled systemd-resolved.service 2>/dev/null | grep -q "^masked$"'
end
