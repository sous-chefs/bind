require 'spec_helper'

describe 'creating a basic configuration' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_config']
    ).converge('bind_test::spec_basic')
  end

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
      expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
        expect(content).to include('listen-on-v6 { any; };')
      }
    end

    it 'has no query logging enabled' do
      expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
        expect(content).to_not include('logging {')
        expect(content).to_not include('file "query.log" versions 2 size 1m;')
      }
    end
  end

  context 'the main named config file' do
    it 'has the root hints zone specified' do
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to include('zone "." IN {
  type hint;
  file "named.ca"')
      }
    end

    it 'has no primary or secondary zones' do
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to_not include('type master;')
        expect(content).to_not include('type slave;')
      }
    end
  end
end

describe 'overridden defaults' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_config']
    ).converge('bind_test::spec_overridden')
  end

  it 'puts default zone files in place' do
    expect(chef_run).to create_cookbook_file('/test/etc/named.rfc1912.zones')
    expect(chef_run).to create_cookbook_file('/test/var/named.empty')
    expect(chef_run).to create_cookbook_file('/test/var/named.ca')
    expect(chef_run).to create_cookbook_file('/test/var/named.loopback')
    expect(chef_run).to create_cookbook_file('/test/var/named.localhost')
  end

  context 'the options file' do
    it 'has ipv6 enabled by default' do
      expect(chef_run).to render_file('/etc/bind/bind.options').with_content { |content|
        expect(content).to_not include('listen-on-v6 { any; };')
      }
    end

    it 'has query logging enabled' do
      expect(chef_run).to render_file('/etc/bind/bind.options').with_content { |content|
        expect(content).to include('logging {')
        expect(content).to include('file "query.log" versions 2 size 1m;')
      }
    end

    it 'renders manually passed options' do
      expect(chef_run).to render_file('/etc/bind/bind.options').with_content { |content|
        expect(content).to include('recursion yes;')
        expect(content).to include('notify no;')
      }
    end
  end

  it 'creates the main config file' do
    expect(chef_run).to render_file('/etc/bind/bind.conf')
  end
end

describe 'additional config files' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_config']
    ).converge('bind_test::spec_additional_config_files')
  end

  it 'creates the main config file' do
    expect(chef_run).to render_file('/etc/named.conf')
      .with_content('include "/etc/named/additional.conf";')
    expect(chef_run).to render_file('/etc/named.conf')
      .with_content('include "/etc/named/additional-view.conf";')
  end
end
