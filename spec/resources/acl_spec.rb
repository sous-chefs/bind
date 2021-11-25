require 'spec_helper'

describe 'adding access control lists' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(bind_config bind_acl)
    ).converge('bind_test::spec_acl')
  end

  include_context 'version_stub'

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_acl('internal')
    expect(chef_run).to create_bind_acl('external')
    expect(chef_run).to create_bind_acl('external-private-interfaces')
  end

  it 'renders the acl into the options file' do
    expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
      expect(content).to match(/^acl "internal" {/)
      expect(content).to match(/^acl "external-private-interfaces" {/)
    }
  end
end
