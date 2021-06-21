require 'spec_helper'

describe 'set server options' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(bind_service bind_config bind_server)
    ).converge('bind_test::spec_server')
  end

  context 'a single server with multiple free-form options' do
    it 'uses the custom resource' do
      expect(chef_run).to create_bind_server('10.1.1.1')
    end

    it 'render the server stanza containing the option' do
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to match(/bogus yes/)
      }
    end
  end
end
