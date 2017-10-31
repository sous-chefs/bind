module BindCookbook
  module Helpers
    def default_property_for(property_name)
      if node['platform_family'] == 'debian'
        debian_property_for(property_name)
      else
        rhel_property_for(property_name)
      end
    end

    def debian_property_for(property_name)
      {
        sysconfdir: '/etc/bind',
        vardir: '/var/cache/bind',
        packages: %w(bind9 bind9utils),
        run_user: 'bind',
        run_group: 'bind',
        options_file: '/etc/bind/named.options',
        conf_file: '/etc/bind/named.conf',
        service_name: 'bind9',
        rndc_key_file: '/etc/bind/rndc.key',
      }[property_name]
    end

    def rhel_property_for(property_name)
      {
        sysconfdir: '/etc/named',
        vardir: '/var/named',
        packages: ['bind', 'bind-utils', 'bind-libs'],
        run_user: 'named',
        run_group: 'named',
        options_file: '/etc/named/named.options',
        conf_file: '/etc/named.conf',
        service_name: 'named',
        rndc_key_file: '/etc/rndc.key',
      }[property_name]
    end
  end
end
