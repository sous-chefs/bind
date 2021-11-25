require 'spec_helper'

describe 'creating a basic configuration' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_config']
    ).converge('bind_test::spec_basic')
  end

  include_context 'version_stub'

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_config('default')
  end

  it 'puts default zone files in place' do
    expect(chef_run).to create_cookbook_file('/etc/named/named.rfc1912.zones')
    expect(chef_run).to create_cookbook_file('/var/named/named.empty')
    expect(chef_run).to create_cookbook_file('/var/named/named.ca')
    expect(chef_run).to create_cookbook_file('/var/named/named.loopback')
    expect(chef_run).to create_cookbook_file('/var/named/named.localhost')
  end

  context 'the basic options file' do
    it 'has ipv6 enabled by default' do
      expect(chef_run).to render_file('/etc/named/named.options').with_content('listen-on-v6 { any; };')
    end

    it 'has no query logging enabled' do
      expect(chef_run).to_not render_file('/etc/named/named.options').with_content('logging {')
      expect(chef_run).to_not render_file('/etc/named/named.options').with_content('file "query.log" versions 2 size 1m;')
    end
  end

  context 'the main named config file' do
    it 'has the root hints zone specified' do
      expect(chef_run).to render_file('/etc/named.conf').with_content(%(zone "." IN {\n  type hint;\n  file "named.ca"))
    end

    it 'has no primary or secondary zones' do
      expect(chef_run).to_not render_file('/etc/named.conf').with_content('type master;')
      expect(chef_run).to_not render_file('/etc/named.conf').with_content('type slave;')
    end
  end
end

describe 'overridden defaults' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_config']
    ).converge('bind_test::spec_overridden')
  end

  include_context 'version_stub'

  it 'puts default zone files in place' do
    expect(chef_run).to create_cookbook_file('/test/etc/named.rfc1912.zones')
    expect(chef_run).to create_cookbook_file('/test/var/named.empty')
    expect(chef_run).to create_cookbook_file('/test/var/named.ca')
    expect(chef_run).to create_cookbook_file('/test/var/named.loopback')
    expect(chef_run).to create_cookbook_file('/test/var/named.localhost')
  end

  context 'the options file' do
    it 'has ipv6 enabled by default' do
      expect(chef_run).to_not render_file('/etc/bind/bind.options').with_content('listen-on-v6 { any; };')
    end

    it 'renders manually passed options' do
      expect(chef_run).to render_file('/etc/bind/bind.options').with_content('recursion yes;')
      expect(chef_run).to render_file('/etc/bind/bind.options').with_content('notify no;')
    end

    it 'renders list of primaries' do
      expect(chef_run).to render_file('/etc/bind/bind.conf').with_content(
        <<~EOF
          primaries test {
            1.2.3.4;
            5.6.7.8;
            9.10.11.12;
          };
        EOF
      )
    end

    it 'creates the main config file' do
      expect(chef_run).to render_file('/etc/bind/bind.conf')
    end

    context 'on old versions of bind' do
      before do
        stubs_for_provider('bind_config[default]') do |provider|
          allow(provider).to receive_shell_out('named -v', stdout: 'BIND 9.11.26 (Extended Support Version) <id:3ff8620>')
        end
      end

      it 'uses "masters" option instead of "primaries"' do
        expect(chef_run).to render_file('/etc/bind/bind.conf').with_content(
          <<~EOF
            masters test {
              1.2.3.4;
              5.6.7.8;
              9.10.11.12;
            };
          EOF
        )
      end
    end
  end
end

describe 'additional config files' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_config']
    ).converge('bind_test::spec_additional_config_files')
  end

  include_context 'version_stub'

  it 'creates the main config file' do
    expect(chef_run).to render_file('/etc/named.conf').with_content('include "/etc/named/additional.conf";')
    expect(chef_run).to render_file('/etc/named.conf').with_content('include "/etc/named/additional-view.conf";')
  end
end
