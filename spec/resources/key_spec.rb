require 'spec_helper'

describe 'key stanza' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(bind_config bind_key)
    ).converge('bind_test::spec_key')
  end

  include_context 'version_stub'

  context 'add a key to the configuration' do
    it 'uses the custom resource' do
      expect(chef_run).to create_bind_key('secret-key')
    end

    it 'render the server stanza containing the option' do
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to match(/secret "this_is_a_secret_key";/)
        expect(content).to match(/algorithm hmac-sha256;/)
      }
    end
  end
end
