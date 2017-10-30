property :sysconfdir, String, default: lazy { default_property_for(:sysconfdir) }
property :vardir, String, default: lazy { default_property_for(:vardir) }
property :package_name, [String, Array], default: lazy { default_property_for(:packages) }
property :run_user, String, default: lazy { default_property_for(:run_user) }
property :run_group, String, default: lazy { default_property_for(:run_group) }
property :run_user_id, [NilClass, Integer], default: lazy { default_property_for(:run_user_id) }
property :run_group_id, [NilClass, Integer], default: lazy { default_property_for(:run_group_id) }
property :service_name, String, default: lazy { default_property_for(:service_name) }

include BindCookbook::Helpers

action :create do
  packages = if new_resource.package_name.is_a?(String)
               [new_resource.package_name]
             else
               new_resource.package_name
             end

  packages.each do |pkg|
    package pkg do
      action :install
    end
  end

  directory new_resource.sysconfdir do
    owner new_resource.run_user
    group new_resource.run_group
    mode 0o0750
    action :create
  end

  directory new_resource.vardir do
    owner new_resource.run_user
    group new_resource.run_group
    mode 0o0750
    action :create
  end

  %w(data primary secondary).each do |dir_name|
    directory "#{new_resource.vardir}/#{dir_name}" do
      owner new_resource.run_user
      group new_resource.run_group
      mode 0o0770
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
