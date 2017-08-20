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

  it 'creates a user and group' do
    expect(chef_run).to create_group('named').with(gid: 25)
    expect(chef_run).to create_user('named').with(gid: 'named', uid: 25)
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
  end

  it 'starts the service' do
    expect(chef_run).to start_service('named')
    expect(chef_run).to enable_service('named')
  end
end

describe 'overridden defaults on centos 7' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: ['bind_service']
    ).converge('bind_test::spec_overridden')
  end

  it 'creates a user and group' do
    expect(chef_run).to create_group('bind').with(gid: 892)
    expect(chef_run).to create_user('bind').with(gid: 'bind', uid: 891)
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

  it 'creates a user and group' do
    expect(chef_run).to create_group('bind').with(gid: nil)
    expect(chef_run).to create_user('bind').with(gid: 'bind', uid: nil)
  end

  it 'installs bind' do
    expect(chef_run).to install_package('bind9')
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
  end

  it 'starts the service' do
    expect(chef_run).to start_service('bind9')
    expect(chef_run).to enable_service('bind9')
  end
end
