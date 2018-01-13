# frozen_string_literal: true
require 'spec_helper'

describe 'adding a single view' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: %w(bind_config bind_view bind_primary_zone)
    ).converge('bind_test::spec_single_view')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_view('default')
    expect(chef_run).to create_bind_primary_zone('example.com')
    expect(chef_run).to create_bind_primary_zone('example.org')
    expect(chef_run).to create_cookbook_file('example.org')
  end

  it 'will copy the zone file from the test cookbook' do
    expect(chef_run).to render_file('/var/named/primary/db.example.com').with_content { |content|
      expect(content).to include '$ORIGIN example.com.'
    }
  end

  it 'will place the config in the named config' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include 'zone "example.com" IN {'
      expect(content).to include 'file "primary/db.example.com";'
    }
  end

  it 'will add a zone with no view name to the default view' do
    stanza = <<~CONFIG_FRAGMENT
      view "default" {

        zone "example.com" IN {
          type master;
    CONFIG_FRAGMENT
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include stanza
    }
  end
end
