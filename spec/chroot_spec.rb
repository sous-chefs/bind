# frozen_string_literal: true
require 'spec_helper'

describe 'bind_test::chroot' do
  context 'on CentOS 6 chrooted' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos', version: '6.9', step_into: %w(
          bind_service bind_config bind_acl
        )
      ).converge(described_recipe)
    end

    %w(bind-chroot bind-utils bind-libs).each do |bind_package|
      it "installs package #{bind_package}" do
        expect(chef_run).to install_package(bind_package)
      end
    end

    it 'notifies service[named]' do
      config_template = chef_run.template('/var/named/chroot/etc/named/named.options')
      expect(config_template).to notify('bind_service[default]').to(:restart)
    end
  end

  context 'on CentOS 7 chrooted' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos', version: '7.3.1611', step_into: %w(
          bind_service bind_config bind_acl
        )
      ).converge(described_recipe)
    end

    %w(bind-chroot bind-utils bind-libs).each do |bind_package|
      it "installs package #{bind_package}" do
        expect(chef_run).to install_package(bind_package)
      end
    end

    it 'creates /var/named/chroot with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/var/named/chroot').with(
        mode: '0750',
        user: 'root',
        group: 'named'
      )
    end

    %w(dev etc var var/log var/run).each do |subdir|
      it "creates #{::File.join('/var/named/chroot', subdir)} with mode 750 and owner named" do
        expect(chef_run).to create_directory(::File.join('/var/named/chroot', subdir)).with(
          mode: '0750',
          user: 'named'
        )
      end
    end

    it 'creates /var/named/chroot/var/named with mode 750 and owner named' do
      expect(chef_run).to create_directory('/var/named/chroot/var/named').with(
        mode: '0750',
        user: 'named'
      )
    end

    it 'creates /var/named/chroot/var/named/dynamic with mode 750 and owner named' do
      expect(chef_run).to create_directory('/var/named/chroot/var/named/dynamic').with(
        mode: '0750',
        user: 'named'
      )
    end

    it 'creates /var/named/chroot/etc/named with mode 750 and owner named' do
      expect(chef_run).to create_directory('/var/named/chroot/etc/named').with(
        mode: '0750',
        user: 'named'
      )
    end

    it 'renders file /var/named/chroot/etc/named/named.options' do
      expect(chef_run).to render_file('/var/named/chroot/etc/named/named.options')
    end

    it 'renders file /var/named/chroot/etc/named/named.rfc1912.zones' do
      expect(chef_run).to create_cookbook_file('/var/named/chroot/etc/named/named.rfc1912.zones')
    end

    it 'renders file /var/named/chroot/etc/named.conf with included files' do
      expect(chef_run).to render_file('/var/named/chroot/etc/named.conf').with_content(%r{include "/etc/named/named.options"})
      expect(chef_run).to render_file('/var/named/chroot/etc/named.conf').with_content(%r{include "/etc/named/named.rfc1912.zones"})
    end

    %w(named.empty named.loopback named.localhost named.ca).each do |var_file|
      it "it creates cookbook file /var/named/chroot/var/named/#{var_file}" do
        expect(chef_run).to create_cookbook_file("/var/named/chroot/var/named/#{var_file}")
      end
    end

    %w(data primary secondary).each do |subdir|
      it "creates subdirectory /var/named/chroot/var/named/#{subdir}" do
        expect(chef_run).to create_directory("/var/named/chroot/var/named/#{subdir}")
      end
    end

    it 'executes generate_rndc_key' do
      expect(chef_run).to run_execute('generate_rndc_key')
    end

    it 'notifies service[named-chroot]' do
      config_template = chef_run.template('/var/named/chroot/etc/named/named.options')
      expect(config_template).to notify('bind_service[default]').to(:restart)
    end
  end

  context 'on Ubuntu 14.04 chrooted' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu', version: '14.04', step_into: %w(
          bind_service bind_config bind_acl
        )
      ).converge(described_recipe)
    end

    %w(bind9 bind9-host bind9utils).each do |bind_package|
      it "installs package #{bind_package}" do
        expect(chef_run).to install_package(bind_package)
      end
    end

    it 'creates /var/bind9/chroot with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/var/bind9/chroot').with(
        mode: '0750',
        user: 'root',
        group: 'bind'
      )
    end

    %w(dev etc var var/log var/run).each do |subdir|
      it "creates #{::File.join('/var/bind9/chroot', subdir)} with mode 750 and owner bind" do
        expect(chef_run).to create_directory(::File.join('/var/bind9/chroot', subdir)).with(
          mode: '0750',
          user: 'bind'
        )
      end
    end

    it 'creates /var/bind9/chroot/var/cache/bind with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind').with(
        mode: '0750',
        user: 'bind'
      )
    end

    it 'creates /var/bind9/chroot/var/cache/bind/dynamic with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind/dynamic').with(
        mode: '0750',
        user: 'bind'
      )
    end

    it 'creates /var/bind9/chroot/etc/bind with mode 750 and owner bind' do
      expect(chef_run).to create_directory('/var/bind9/chroot/etc/bind').with(
        mode: '0750',
        user: 'bind'
      )
    end

    it 'renders file /var/bind9/chroot/etc/bind/named.options' do
      expect(chef_run).to render_file('/var/bind9/chroot/etc/bind/named.options')
    end

    it 'renders file /var/bind9/chroot/etc/bind/named.rfc1912.zones' do
      expect(chef_run).to create_cookbook_file('/var/bind9/chroot/etc/bind/named.rfc1912.zones')
    end

    it 'renders file /var/bind9/chroot/etc/bind/named.conf with included files' do
      expect(chef_run).to render_file('/var/bind9/chroot/etc/bind/named.conf').with_content(%r{include "/etc/bind/named.options"})
      expect(chef_run).to render_file('/var/bind9/chroot/etc/bind/named.conf').with_content(%r{include "/etc/bind/named.rfc1912.zones"})
    end

    %w(named.empty named.loopback named.localhost named.ca).each do |var_file|
      it "it creates cookbook file /var/bind9/chroot/var/cache/bind/#{var_file}" do
        expect(chef_run).to create_cookbook_file("/var/bind9/chroot/var/cache/bind/#{var_file}")
      end
    end

    %w(data primary secondary).each do |subdir|
      it "creates subdirectory /var/bind9/chroot/var/cache/bind/#{subdir}" do
        expect(chef_run).to create_directory("/var/bind9/chroot/var/cache/bind/#{subdir}")
      end
    end

    it 'renders file /etc/default/bind9' do
      expect(chef_run).to render_file('/etc/default/bind9')
    end

    it 'renders file /etc/init.d/bind9' do
      expect(chef_run).to render_file('/etc/init.d/bind9')
    end

    %w(null random urandom).each do |d|
      it "executes mknod #{::File.join('/var/bind9/chroot/dev', d)}" do
        expect(chef_run).to run_execute("mknod_#{d}")
      end

      it "doesn't execute chmod on #{::File.join('/var/bind9/chroot/dev', d)}" do
        expect(chef_run).to_not run_execute("chmod_dev_#{d}")
      end

      it "doesn't execute chgrp on #{::File.join('/var/bind9/chroot/dev', d)}" do
        expect(chef_run).to_not run_execute("chgrp_dev_#{d}")
      end
    end

    it 'executes generate_rndc_key' do
      expect(chef_run).to run_execute('generate_rndc_key')
    end

    it 'notifies service[bind]' do
      config_template = chef_run.template('/var/bind9/chroot/etc/bind/named.options')
      expect(config_template).to notify('bind_service[default]').to(:restart)
    end
  end
end
