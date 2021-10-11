require 'spec_helper'

describe 'adding primary zones' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(bind_config bind_primary_zone)
    ).converge('bind_test::spec_primary_zone')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_primary_zone('example.org')
    expect(chef_run).to create_bind_primary_zone('example.org')
    expect(chef_run).to create_cookbook_file('example.org')
  end

  it 'will copy the zone file from the test cookbook' do
    expect(chef_run).to render_file('/var/named/primary/db.example.org').with_content { |content|
      expect(content).to include '$ORIGIN example.org.'
    }
  end

  it 'will place the config in the named config' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include 'zone "example.org" IN {'
      expect(content).to include 'file "primary/db.example.org";'
    }
  end

  it 'will add options to the zone' do
    stanza = <<~EOF
      zone "example.org" IN {
        type master;
        file "primary/db.example.org";
        allow-transfer { none; };
      };
    EOF
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end

  it 'will create a zone file with action :create_if_missing' do
    expect(chef_run).to create_cookbook_file_if_missing('example.net').with(
      path: '/var/named/primary/db.example.net'
    )
  end
end
