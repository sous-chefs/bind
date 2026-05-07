# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure(&:raise_errors_for_deprecations!)

shared_context 'version_stub' do
  before do
    stubs_for_provider('bind_config[default]') do |provider|
      allow(provider).to receive_shell_out('named -v', stdout: 'BIND 9.16.23 (Extended Support Version) <id:fde3b1f>')
    end
  end
end
