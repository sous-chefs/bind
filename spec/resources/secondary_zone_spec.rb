require 'spec_helper'

describe 'adding secondary zones' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: %w(bind_config bind_secondary_zone)
    ).converge('bind_test::spec_secondary_zone')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_secondary_zone('example.com')
  end

  it 'will render secondary with no options' do
    stanza = <<~EOF
      zone "example.com" IN {
        type slave;
        file "secondary/db.example.com";
        masters { 10.1.1.1; };
      };
    EOF
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }

  end

  it 'will render secondary zone with options specified' do
    stanza = <<~EOF
      zone "example.org" IN {
        type slave;
        file "secondary/db.example.org";
        masters { 10.1.1.2; 10.1.1.3; };
        zone-statistics terse;
      };
    EOF
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end
end