require 'spec_helper'

describe 'adding linked zone' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu', version: '16.04', step_into: %w(
        bind_config bind_view bind_primary_zone bind_linked_zone
      )
    ).converge('bind_test::spec_linked_zones')
  end

  include_context 'version_stub'

  it 'will add two views to the resource collection' do
    expect(chef_run).to create_bind_view('internal')
    expect(chef_run).to create_bind_view('external')
  end

  it 'render view based filename' do
    expect(chef_run).to render_file('/etc/bind/named.conf').with_content { |content|
      expect(content).to include 'file "primary/db.sub.example.com";'
    }
  end

  it 'will create the zone file' do
    expect(chef_run).to render_file('/var/cache/bind/primary/db.sub.example.com')
  end

  it 'will configure internal zone in the internal view' do
    expect(chef_run).to render_file('/etc/bind/named.conf').with_content { |content|
      expect(content).to match(
        /^view "internal"(?:.*?)^\s+zone "sub.example.com"(?:.*?)^};/m
      )
    }
  end

  it 'will configure linked zones in the external view' do
    expect(chef_run).to render_file('/etc/bind/named.conf').with_content { |content|
      expect(content).to match(
        /^view "external"(?:.*?)^\s+zone "sub.example.com"(?:.*?)^};/m
      )
    }
  end

  it 'will render linked zone' do
    stanza = <<~EOF
    view "external" {
      include "/etc/bind/named.rfc1912.zones";
      recursion no;

      zone "sub.example.com" IN {
        in-view internal;
      };

      zone "." IN {
        type hint;
        file "named.ca";
      };
    };
    EOF
    expect(chef_run).to render_file('/etc/bind/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end
end
