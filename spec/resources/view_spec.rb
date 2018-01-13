# frozen_string_literal: true
require 'spec_helper'

describe 'adding a single view' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: %w(
        bind_config
        bind_view
        bind_primary_zone
        bind_secondary_zone
      )
    ).converge('bind_test::spec_single_view')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_view('internal')
    expect(chef_run).to create_bind_primary_zone('example.com')
    expect(chef_run).to create_bind_secondary_zone('example.org')
    expect(chef_run).to create_cookbook_file('example.com')
  end

  it 'will place the config in the named config' do
    expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
      expect(content).to include 'zone "example.com" IN {'
      expect(content).to include 'file "primary/db.example.com";'
      expect(content).to include 'file "secondary/db.example.org";'
    }
  end

  it 'will add a zone with no view name to the default view' do
    stanza = <<~CONFIG_FRAGMENT
      view "internal" {

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
      platform: 'centos', version: '7.3.1611', step_into: %w(bind_config bind_view bind_primary_zone)
    ).converge('bind_test::spec_single_view_with_options')
  end

  it 'will add a zone with no view name to the default view' do
    stanza = <<~CONFIG_FRAGMENT
      view "default" {

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
