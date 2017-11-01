require 'spec_helper'

describe 'adding forward only zones' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: %w(bind_config bind_forward_zone)
    ).converge('bind_test::spec_forward_zone')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_forward_zone('example.com')
  end

  it 'will render forwarder with no options' do
    stanza = <<~EOF
      zone "example.com" IN {
        type forward;
        forwarders {  };
        forward only;
        delegation-only false;
      };
    EOF
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }

  end

  it 'will render zone forwarder with all options specified' do
    stanza = <<~EOF
      zone "example.org" IN {
        type forward;
        forwarders { 10.2.1.1; 10.3.2.2; };
        forward first;
        delegation-only true;
      };
    EOF
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end
end