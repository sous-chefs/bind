require 'spec_helper'

describe 'adding a single view' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(
        bind_config
        bind_view
        bind_primary_zone
        bind_secondary_zone
        bind_forward_zone
      )
    ).converge('bind_test::spec_single_view')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_view('internal')
    expect(chef_run).to create_bind_primary_zone('example.com')
    expect(chef_run).to create_bind_secondary_zone('example.org')
    expect(chef_run).to create_bind_forward_zone('example.net')
    expect(chef_run).to create_cookbook_file('example.com')
  end

  it 'will place the config in the named config' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include 'zone "example.com" IN {'
      expect(content).to include 'file "primary/db.example.com";'
      expect(content).to include 'file "secondary/db.example.org";'
      expect(content).to include %(zone "example.net" IN {\n    type forward;)
    }
  end

  it 'will add a zone with no view name to the default view' do
    stanza = <<~CONFIG_FRAGMENT
      view "internal" {
        include "/etc/named/named.rfc1912.zones";

        zone "example.com" IN {
          type master;
    CONFIG_FRAGMENT
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end
end

describe 'adding a single view with options' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(bind_config bind_view bind_primary_zone)
    ).converge('bind_test::spec_single_view_with_options')
  end

  it 'will add a zone with no view name to the default view' do
    stanza = <<~CONFIG_FRAGMENT
      view "default" {
        include "/etc/named/named.rfc1912.zones";

        match-clients {
          10.0.0.0/8;
          192.168.0.0/16;
        };

        match-destinations {
          172.16.0.0/16;
        };

        match-recursive-only yes;
        recursion no;
    CONFIG_FRAGMENT
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end
end

describe 'adding multiple views' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(
        bind_config bind_view bind_primary_zone bind_primary_zone_template
      )
    ).converge('bind_test::spec_multiple_views')
  end

  it 'will add two views to the resource collection' do
    expect(chef_run).to create_bind_view('internal')
    expect(chef_run).to create_bind_view('external')
  end

  it 'render view based filenames' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include 'file "primary/db.internal-example.com";'
      expect(content).to include 'file "primary/db.external-example.com";'
    }
  end

  it 'will create the zone files' do
    expect(chef_run).to render_file('/var/named/primary/db.internal.example.com')
    expect(chef_run).to render_file('/var/named/primary/db.internal-example.com')
    expect(chef_run).to render_file('/var/named/primary/db.external-example.com')
  end

  it 'will configure internal zones in the internal view' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to match(
        /^view "internal"(?:.*?)^\s+zone "internal.example.com"(?:.*?)^};/m
      )
      expect(content).to match(
        /^view "internal"(?:.*?)^\s+zone "example.com"(?:.*?)^};/m
      )
    }
  end

  it 'will configure external zones in the external view' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to match(
        /^view "external"(?:.*?)^\s+zone "example.com"(?:.*?)^};/m
      )
    }
  end
end
