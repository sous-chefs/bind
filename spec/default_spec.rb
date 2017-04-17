require 'spec_helper'

describe 'bind::default' do
  context 'on unspecified platform (EL 5/6 as reference)' do
    let(:chef_run) {
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.8')
        .converge(described_recipe)
    }
    let(:checkconf) { chef_run.execute('named-checkconf') }

    %w(bind bind-utils bind-libs).each do |bind_package|
      it "installs package #{bind_package}" do
        expect(chef_run).to install_package(bind_package)
      end
    end

    it 'creates /var/named with mode 750 and owner named' do
      expect(chef_run).to create_directory('/var/named').with(
        mode: 00750,
        user: 'named'
      )
    end

    it 'creates /etc/named with mode 750 and owner named' do
      expect(chef_run).to create_directory('/etc/named').with(
        mode: 00750,
        user: 'named'
      )
    end

    it 'renders file /etc/named/named.options' do
      expect(chef_run).to render_file('/etc/named/named.options')
    end

    it 'renders file /etc/named/named.rfc1912.zones' do
      expect(chef_run).to create_cookbook_file('/etc/named/named.rfc1912.zones')
    end

    it 'renders file /etc/named.conf with included files' do
      expect(chef_run).to render_file('/etc/named.conf').with_content(%r{include "/etc/named/named.options"})
      expect(chef_run).to render_file('/etc/named.conf').with_content(%r{include "/etc/named/named.rfc1912.zones"})
    end

    %w(named.empty named.loopback named.localhost named.ca).each do |var_file|
      it "it creates cookbook file /var/named/#{var_file}" do
        expect(chef_run).to create_cookbook_file("/var/named/#{var_file}")
      end
    end

    it 'executes rndc-confgen -a' do
      expect(chef_run).to run_execute('rndc-confgen -a')
    end

    %w(data slaves master).each do |subdir|
      it "creates subdirectory /var/named/#{subdir}" do
        expect(chef_run).to create_directory("/var/named/#{subdir}")
      end
    end

    it 'named-checkconf notifies bind service' do
      expect(checkconf).to notify('service[bind]').to(:start).immediately
      expect(checkconf).to notify('service[bind]').to(:enable).immediately
    end
  end

  context 'on virtual guest for any platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.8') do |node|
        node.automatic['virtualization']['role'] = 'guest'
      end.converge(described_recipe)
    end
    let(:checkconf) { chef_run.execute('named-checkconf') }

    it 'executes rndc-confgen -a -r /dev/urandom' do
      expect(chef_run).to run_execute('rndc-confgen -a -r /dev/urandom')
    end
  end

  context 'on Ubuntu 16.04' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe)
    end
    let(:checkconf) { chef_run.execute('named-checkconf') }

    %w(bind9 bind9utils).each do |bind_package|
      it "installs package #{bind_package}" do
        expect(chef_run).to install_package(bind_package)
      end
    end

    it 'creates /var/cache/bind with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/var/cache/bind').with(
        mode: 00750,
        user: 'bind'
      )
    end

    it 'creates /etc/bind with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/etc/bind').with(
        mode: 00750,
        user: 'bind'
      )
    end

    it 'renders file /etc/bind/named.options' do
      expect(chef_run).to render_file('/etc/bind/named.options')
    end

    it 'renders file /etc/bind/named.rfc1912.zones' do
      expect(chef_run).to create_cookbook_file('/etc/bind/named.rfc1912.zones')
    end

    it 'renders file /etc/bind/named.conf with included files' do
      expect(chef_run).to render_file('/etc/bind/named.conf').with_content(%r{include "/etc/bind/named.options"})
      expect(chef_run).to render_file('/etc/bind/named.conf').with_content(%r{include "/etc/bind/named.rfc1912.zones"})
    end

    %w(named.empty named.loopback named.localhost named.ca).each do |var_file|
      it "it creates cookbook file /var/cache/bind/#{var_file}" do
        expect(chef_run).to create_cookbook_file("/var/cache/bind/#{var_file}")
      end
    end

    %w(data slaves master).each do |subdir|
      it "creates subdirectory /var/cache/bind/#{subdir}" do
        expect(chef_run).to create_directory("/var/cache/bind/#{subdir}")
      end
    end

    it 'named-checkconf notifies service[bind]' do
      expect(checkconf).to notify('service[bind]').to(:start).immediately
      expect(checkconf).to notify('service[bind]').to(:enable).immediately
    end
  end
end
