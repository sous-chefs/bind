require 'spec_helper'

describe 'basic recipe on centos 8' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_service']
    ).converge('bind_test::spec_basic')
  end

  include_context 'version_stub'

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_service('default')
    expect(chef_run).to start_bind_service('default')
  end

  it 'installs bind' do
    expect(chef_run).to install_package(%w(bind bind-utils bind-libs))
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

describe 'chroot recipe on ubuntu 18.04' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu', version: '18.04', step_into: ['bind_service']
    ).converge('bind_test::spec_chroot')
  end

  include_context 'version_stub'

  let(:mknod_null)    { chef_run.execute('mknod_null') }
  let(:mknod_random)  { chef_run.execute('mknod_random') }
  let(:mknod_urandom) { chef_run.execute('mknod_urandom') }
  let(:chgrp_null)    { chef_run.execute('chgrp_dev_null') }
  let(:chgrp_random)  { chef_run.execute('chgrp_dev_random') }
  let(:chgrp_urandom) { chef_run.execute('chgrp_dev_urandom') }
  let(:chmod_null)    { chef_run.execute('chmod_dev_null') }
  let(:chmod_random)  { chef_run.execute('chmod_dev_random') }
  let(:chmod_urandom) { chef_run.execute('chmod_dev_urandom') }

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_service('default')
    expect(chef_run).to start_bind_service('default')
  end

  it 'installs bind' do
    expect(chef_run).to install_package(%w(bind9 bind9-host bind9utils dnsutils))
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

  it 'run mknod_null actions and notifications' do
    expect(chef_run).to run_execute('mknod_null')
    expect(chef_run).to_not run_execute('chmod_dev_null')
    expect(chef_run).to_not run_execute('chgrp_dev_null')
    expect(mknod_null).to notify('execute[chmod_dev_null]').to(:run).immediately
    expect(mknod_null).to notify('execute[chgrp_dev_null]').to(:run).immediately
    expect(chgrp_null).to do_nothing
    expect(chmod_null).to do_nothing
  end

  it 'run mknod_random actions and notifications' do
    expect(chef_run).to run_execute('mknod_random')
    expect(chef_run).to_not run_execute('chmod_dev_random')
    expect(chef_run).to_not run_execute('chgrp_dev_random')
    expect(mknod_random).to notify('execute[chmod_dev_random]').to(:run).immediately
    expect(mknod_random).to notify('execute[chgrp_dev_random]').to(:run).immediately
    expect(chgrp_random).to do_nothing
    expect(chmod_random).to do_nothing
  end

  it 'run mknod_urandom actions and notifications' do
    expect(chef_run).to run_execute('mknod_urandom')
    expect(chef_run).to_not run_execute('chmod_dev_urandom')
    expect(chef_run).to_not run_execute('chgrp_dev_urandom')
    expect(mknod_urandom).to notify('execute[chmod_dev_urandom]').to(:run).immediately
    expect(mknod_urandom).to notify('execute[chgrp_dev_urandom]').to(:run).immediately
    expect(chgrp_urandom).to do_nothing
    expect(chmod_urandom).to do_nothing
  end

  it 'starts the service' do
    expect(chef_run).to start_service('bind9')
    expect(chef_run).to enable_service('bind9')
  end
end

describe 'chroot recipe on centos 8' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_service']
    ).converge('bind_test::spec_chroot')
  end

  include_context 'version_stub'

  it 'uses the custom resource' do
    expect(chef_run).to create_bind_service('default')
    expect(chef_run).to start_bind_service('default')
  end

  it 'installs bind' do
    expect(chef_run).to install_package(%w(bind-chroot bind-utils bind-libs))
  end

  it 'creates configuration directories' do
    expect(chef_run).to create_directory('/var/named/chroot').with(
      user: 'root',
      group: 'named'
    )
    expect(chef_run).to create_directory('/var/named')
    expect(chef_run).to create_directory('/var/named/primary')
    expect(chef_run).to create_directory('/var/named/secondary')
    expect(chef_run).to create_directory('/var/named/data')
    expect(chef_run).to create_directory('/var/named/dynamic')
  end

  it 'does not run mknod_null actions and notifications' do
    expect(chef_run).to_not run_execute('mknod_null')
  end

  it 'does not run mknod_random actions and notifications' do
    expect(chef_run).to_not run_execute('mknod_random')
  end

  it 'run mknod_urandom actions and notifications' do
    expect(chef_run).to_not run_execute('mknod_urandom')
  end

  it 'starts the service' do
    expect(chef_run).to_not start_service('named')
    expect(chef_run).to_not enable_service('named')
    expect(chef_run).to start_service('named-chroot')
    expect(chef_run).to enable_service('named-chroot')
  end
end

describe 'overridden defaults on centos 8' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: ['bind_service']
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

describe 'basic recipe on ubuntu 18.04' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu', version: '18.04', step_into: ['bind_service']
    ).converge('bind_test::spec_basic')
  end

  include_context 'version_stub'

  it 'installs bind' do
    expect(chef_run).to install_package(%w(bind9 bind9-host bind9utils dnsutils))
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
