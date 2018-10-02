# frozen_string_literal: true
name 'bind'

description 'Installs/Configures ISC BIND'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '2.2.1'

maintainer 'David Bruce'
maintainer_email 'djb@ragnarok.net'
license 'Apache-2.0'

supports 'ubuntu'
supports 'redhat'
supports 'centos'
supports 'debian'

issues_url 'https://github.com/joyofhex/cookbook-bind/issues'
source_url 'https://github.com/joyofhex/cookbook-bind'
chef_version '>= 12.16'
