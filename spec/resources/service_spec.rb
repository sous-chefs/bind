# frozen_string_literal: true
require 'spec_helper'

describe 'basic recipe on centos 7' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: ['bind_service']
    ).converge('bind_test::spec_basic')
  end

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_service('default')
    expect(chef_run).to start_bind_service('default')
  end

  it 'installs bind' do
    expect(chef_run).to install_package('bind')
    expect(chef_run).to install_package('bind-utils')
    expect(chef_run).to install_package('bind-libs')
  end

  it 'creates configuration directories' do
    expect(chef_run).to create_directory('/etc/named').with(
      user: 'named',
      group: 'named'
    )
    expect(chef_run).to create_directory('/var/named')
    expect(chef_run).to create_directory('/var/named/primary')
    expect(chef_run).to create_directory('/var/named/secondary')
    expect(chef_run).to create_directory('/var/named/data')
    expect(chef_run).to create_directory('/var/named/dynamic')
  end

  it 'starts the service' do
    expect(chef_run).to start_service('named')
    expect(chef_run).to enable_service('named')
  end
end

describe 'chroot recipe on ubuntu 14.04' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu', version: '14.04', step_into: ['bind_service']
    ).converge('bind_test::spec_chroot')
  end
  let(:mknod_null)    { chef_run.execute('mknod_null') }
  let(:mknod_random)  { chef_run.execute('mknod_random') }
  let(:mknod_urandom) { chef_run.execute('mknod_urandom') }

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_service('default')
    expect(chef_run).to start_bind_service('default')
  end

  it 'installs bind' do
    expect(chef_run).to install_package('bind9')
    expect(chef_run).to install_package('bind9-host')
    expect(chef_run).to install_package('bind9utils')
  end

  it 'creates configuration directories' do
    expect(chef_run).to create_directory('/var/bind9/chroot/etc/bind').with(
      user: 'bind',
      group: 'bind'
    )
    expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind')
    expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind/primary')
    expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind/secondary')
    expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind/data')
    expect(chef_run).to create_directory('/var/bind9/chroot/var/cache/bind/dynamic')
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

  it 'mknod_null sends a notification to execute' do
    expect(mknod_null).to notify('execute[chmod_dev_null]').to(:run).immediately
    expect(mknod_null).to notify('execute[chgrp_dev_null]').to(:run).immediately
  end

  it 'mknod_random sends a notification to execute' do
    expect(mknod_random).to notify('execute[chmod_dev_random]').to(:run).immediately
    expect(mknod_random).to notify('execute[chgrp_dev_random]').to(:run).immediately
  end

  it 'mknod_urandom sends a notification to execute' do
    expect(mknod_urandom).to notify('execute[chmod_dev_urandom]').to(:run).immediately
    expect(mknod_urandom).to notify('execute[chgrp_dev_urandom]').to(:run).immediately
  end

  it 'starts the service' do
    expect(chef_run).to start_service('bind9')
    expect(chef_run).to enable_service('bind9')
  end
end

describe 'chroot recipe on centos 7' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: ['bind_service']
    ).converge('bind_test::spec_chroot')
  end
  let(:mknod_null)    { chef_run.execute('mknod_null') }
  let(:mknod_random)  { chef_run.execute('mknod_random') }
  let(:mknod_urandom) { chef_run.execute('mknod_urandom') }

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_service('default')
    expect(chef_run).to start_bind_service('default')
  end

  it 'installs bind' do
    expect(chef_run).to install_package('bind-chroot')
    expect(chef_run).to install_package('bind-utils')
    expect(chef_run).to install_package('bind-libs')
  end

  it 'creates configuration directories' do
    expect(chef_run).to create_directory('/var/named/chroot/etc/named').with(
      user: 'named',
      group: 'named'
    )
    expect(chef_run).to create_directory('/var/named/chroot/var/named')
    expect(chef_run).to create_directory('/var/named/chroot/var/named/primary')
    expect(chef_run).to create_directory('/var/named/chroot/var/named/secondary')
    expect(chef_run).to create_directory('/var/named/chroot/var/named/data')
    expect(chef_run).to create_directory('/var/named/chroot/var/named/dynamic')
  end

  %w(null random urandom).each do |d|
    it "executes mknod #{::File.join('/var/bind9/chroot/dev', d)}" do
      expect(chef_run).to_not run_execute("mknod_#{d}")
    end

    it "doesn't execute chmod on #{::File.join('/var/bind9/chroot/dev', d)}" do
      expect(chef_run).to_not run_execute("chmod_dev_#{d}")
    end

    it "doesn't execute chgrp on #{::File.join('/var/bind9/chroot/dev', d)}" do
      expect(chef_run).to_not run_execute("chgrp_dev_#{d}")
    end
  end

  %w(random urandom).each do |d|
    it "sends a notification to execute[chmod_dev_#{d}]" do
      expect(mknod_null).to_not notify("execute[chmod_dev_#{d}]").to(:run).immediately
      expect(mknod_null).to_not notify("execute[chgrp_dev_#{d}]").to(:run).immediately
    end
  end

  it 'starts the service' do
    expect(chef_run).to start_service('named-chroot')
    expect(chef_run).to enable_service('named-chroot')
  end
end

describe 'overridden defaults on centos 7' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: ['bind_service']
    ).converge('bind_test::spec_overridden')
  end

  it 'creates configuration directories' do
    expect(chef_run).to create_directory('/test/etc').with(
      user: 'bind',
      group: 'bind'
    )
    expect(chef_run).to create_directory('/test/var')
    expect(chef_run).to create_directory('/test/var/primary')
    expect(chef_run).to create_directory('/test/var/secondary')
    expect(chef_run).to create_directory('/test/var/data')
  end
end

describe 'basic recipe on ubuntu 16.04' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu', version: '16.04', step_into: ['bind_service']
    ).converge('bind_test::spec_basic')
  end

  it 'installs bind' do
    expect(chef_run).to install_package('bind9')
    expect(chef_run).to install_package('bind9-host')
    expect(chef_run).to install_package('bind9utils')
  end

  it 'creates configuration directories' do
    expect(chef_run).to create_directory('/etc/bind').with(
      user: 'bind',
      group: 'bind'
    )
    expect(chef_run).to create_directory('/var/cache/bind')
    expect(chef_run).to create_directory('/var/cache/bind/primary')
    expect(chef_run).to create_directory('/var/cache/bind/secondary')
    expect(chef_run).to create_directory('/var/cache/bind/data')
    expect(chef_run).to create_directory('/var/cache/bind/dynamic')
  end

  it 'starts the service' do
    expect(chef_run).to start_service('bind9')
    expect(chef_run).to enable_service('bind9')
  end
end
