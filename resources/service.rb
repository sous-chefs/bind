# frozen_string_literal: true
property :chroot, [true, false], default: false
property :chroot_dir, [String, nil], default: lazy { default_property_for(:chroot_dir, chroot) }
property :dynamicdir, String, default: lazy { default_property_for(:dynamicdir, chroot) }
property :sysconfdir, String, default: lazy { default_property_for(:sysconfdir, chroot) }
property :vardir, String, default: lazy { default_property_for(:vardir, chroot) }
property :package_name, [String, Array], default: lazy { default_property_for(:packages, chroot) }
property :run_user, String, default: lazy { default_property_for(:run_user, chroot) }
property :run_group, String, default: lazy { default_property_for(:run_group, chroot) }
property :service_name, String, default: lazy { default_property_for(:service_name, chroot) }

include BindCookbook::Helpers

action :create do
  if new_resource.chroot && node['platform'] == 'ubuntu' && node['platform_version'] == '16.04'
    Chef::Log.fatal('Ubuntu 16.04 LTS is incompatible with BIND9 in CHROOT setups')
    Chef::Log.fatal('https://bugs.launchpad.net/ubuntu/+source/bind9/+bug/1630025')
  end

  packages = new_resource.package_name.is_a?(String) ? [new_resource.package_name] : new_resource.package_name

  packages.each do |pkg|
    package pkg do
      action :install
    end
  end

  if new_resource.chroot_dir
    directory new_resource.chroot_dir do
      owner 'root'
      group new_resource.run_group
      mode '0750'
      recursive true
      action :create
    end

    %w(dev etc var var/log var/run).each do |chroot_d|
      directory ::File.join(new_resource.chroot_dir, chroot_d) do
        owner new_resource.run_user
        group new_resource.run_group
        mode '0750'
        action :create
      end
    end

    if node['platform_family'] == 'debian'
      execute 'chmod_dev_null' do
        command "chmod 0660 #{::File.join(new_resource.chroot_dir, 'dev', 'null')}"
        not_if  { ::File.stat(::File.join(new_resource.chroot_dir, 'dev', 'null')).mode == '100660' }
        action :nothing
      end

      execute 'chmod_dev_random' do
        command "chmod 0660 #{::File.join(new_resource.chroot_dir, 'dev', 'random')}"
        not_if  { ::File.stat(::File.join(new_resource.chroot_dir, 'dev', 'random')).mode == '100660' }
        action :nothing
      end

      execute 'chmod_dev_urandom' do
        command "chmod 0660 #{::File.join(new_resource.chroot_dir, 'dev', 'urandom')}"
        not_if  { ::File.stat(::File.join(new_resource.chroot_dir, 'dev', 'urandom')).mode == '100660' }
        action :nothing
      end

      execute 'chgrp_dev_null' do
        command "chgrp #{new_resource.run_user} #{::File.join(new_resource.chroot_dir, 'dev', 'null')}"
        not_if  { Etc.getgrgid(::File.stat(::File.join(new_resource.chroot_dir, 'dev', 'null')).gid).name == new_resource.run_group }
        action :nothing
      end

      execute 'chgrp_dev_random' do
        command "chgrp #{new_resource.run_user} #{::File.join(new_resource.chroot_dir, 'dev', 'random')}"
        not_if  { Etc.getgrgid(::File.stat(::File.join(new_resource.chroot_dir, 'dev', 'random')).gid).name == new_resource.run_group }
        action :nothing
      end

      execute 'chgrp_dev_urandom' do
        command "chgrp #{new_resource.run_user} #{::File.join(new_resource.chroot_dir, 'dev', 'urandom')}"
        not_if  { Etc.getgrgid(::File.stat(::File.join(new_resource.chroot_dir, 'dev', 'urandom')).gid).name == new_resource.run_group }
        action :nothing
      end

      execute 'mknod_null' do
        command "mknod #{::File.join(new_resource.chroot_dir, 'dev', 'null')} c 1 3"
        creates ::File.join(new_resource.chroot_dir, 'dev', 'null')
        notifies :run, 'execute[chmod_dev_null]', :immediately
        notifies :run, 'execute[chgrp_dev_null]', :immediately
      end

      execute 'mknod_random' do
        command "mknod #{::File.join(new_resource.chroot_dir, 'dev', 'random')} c 1 8"
        creates ::File.join(new_resource.chroot_dir, 'dev', 'random')
        notifies :run, 'execute[chmod_dev_random]', :immediately
        notifies :run, 'execute[chgrp_dev_random]', :immediately
      end

      execute 'mknod_urandom' do
        command "mknod #{::File.join(new_resource.chroot_dir, 'dev', 'urandom')} c 1 8"
        creates ::File.join(new_resource.chroot_dir, 'dev', 'urandom')
        notifies :run, 'execute[chmod_dev_urandom]', :immediately
        notifies :run, 'execute[chgrp_dev_urandom]', :immediately
      end
    end
  end

  directory new_resource.sysconfdir do
    owner new_resource.run_user
    group new_resource.run_group
    mode '0750'
    recursive true
    action :create
  end

  directory new_resource.vardir do
    owner new_resource.run_user
    group new_resource.run_group
    mode '0750'
    recursive true
    action :create
  end

  directory new_resource.dynamicdir do
    owner new_resource.run_user
    group new_resource.run_group
    mode '0750'
    recursive true
    action :create
  end

  %w(data primary secondary).each do |dir_name|
    directory ::File.join(new_resource.vardir, dir_name) do
      owner new_resource.run_user
      group new_resource.run_group
      mode '0750'
      action :create
    end
  end
end

action :start do
  with_run_context :root do
    service new_resource.service_name do
      action :enable
      delayed_action :start
    end
  end
end

action :restart do
  service new_resource.service_name do
    action :restart
  end
end
