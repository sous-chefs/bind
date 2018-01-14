# frozen_string_literal: true
module BindCookbook
  module Helpers
    def default_property_for(property_name, chroot)
      if node['platform_family'] == 'debian'
        debian_property_for(property_name, chroot)
      else
        rhel_property_for(property_name, chroot)
      end
    end

    def debian_property_for(property_name, chroot)
      {
        chroot_dir:      chroot ? '/var/bind9/chroot' : nil,
        conf_file:       chroot ? '/var/bind9/chroot/etc/bind/named.conf' : '/etc/bind/named.conf',
        dynamicdir:      chroot ? '/var/bind9/chroot/var/cache/bind/dynamic' : '/var/cache/bind/dynamic',
        forward_zones:   chroot ? '/var/bind9/chroot/etc/bind/forward.zones' : '/etc/bind/forward.zones',
        options_file:    chroot ? '/var/bind9/chroot/etc/bind/named.options' : '/etc/bind/named.options',
        packages:        %w(bind9 bind9-host bind9utils),
        primary_zones:   chroot ? '/var/bind9/chroot/etc/bind/primary.zones' : '/etc/bind/primary.zones',
        rndc_key_file:   chroot ? '/var/bind9/chroot/etc/bind/rndc.key' : '/etc/bind/rndc.key',
        run_group:       'bind',
        run_user:        'bind',
        secondary_zones: chroot ? '/var/bind9/chroot/etc/bind/secondary.zones' : '/etc/bind/secondary.zones',
        service_name:    'bind9',
        sysconfdir:      chroot ? '/var/bind9/chroot/etc/bind' : '/etc/bind',
        vardir:          chroot ? '/var/bind9/chroot/var/cache/bind' : '/var/cache/bind',
      }[property_name]
    end

    def rhel_property_for(property_name, chroot)
      {
        chroot_dir:      chroot ? '/var/named/chroot' : nil,
        conf_file:       '/etc/named.conf',
        dynamicdir:      '/var/named/dynamic',
        forward_zones:   '/etc/named/forward.zones',
        options_file:    '/etc/named/named.options',
        packages:        chroot ? ['bind-chroot', 'bind-utils', 'bind-libs'] : ['bind', 'bind-utils', 'bind-libs'],
        primary_zones:    '/etc/named/primary.zones',
        rndc_key_file:   '/etc/rndc.key',
        run_group:       'named',
        run_user:        'named',
        secondary_zones: '/etc/named/secondary.zones',
        service_name:    chroot && node['platform_version'].to_s >= '7.0' ? 'named-chroot' : 'named',
        sysconfdir:      '/etc/named',
        vardir:          '/var/named',
      }[property_name]
    end
  end
end
