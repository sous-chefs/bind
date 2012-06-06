#
# Cookbook Name:: bind 
# Test:: attributes_spec 
#
# Author:: Eric G. Wolfe
#
# Copyright 2012, Eric G. Wolfe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.join(File.dirname(__FILE__), %w{.. support spec_helper})
require 'chef/node'
require 'chef/platform'

describe 'Bind::Attributes::Default' do
  let(:attr_ns) { 'bind' }

  before do
    @node = Chef::Node.new
    @node.consume_external_attrs(Mash.new(ohai_data), {})
    @node.from_file(File.join(File.dirname(__FILE__), %w{.. .. attributes default.rb}))
  end

  describe "for unknown platform version 3.14" do
    let(:ohai_data) do
      { :platform => "unknown", :platform_version => "3.14" }
    end

    it "sets the package list" do
      @node[attr_ns]['packages'].sort.must_equal %w{ bind bind-utils bind-libs }.sort
    end

    it "sets the var directory" do
      @node[attr_ns]['vardir'].must_equal "/var/named"
    end

    it "sets the sysconf directory" do
      @node[attr_ns]['sysconfdir'].must_equal "/etc/named"
    end

    it "has etc cookbook files" do
      @node[attr_ns]['etc_cookbook_files'].sort.must_equal %w{ named.rfc1912.zones }.sort
    end

    it "has etc template files" do
      @node[attr_ns]['etc_template_files'].sort.must_equal %w{ named.options }.sort
    end

    it "has var cookbook files" do
      @node[attr_ns]['var_cookbook_files'].sort.must_equal %w{ named.empty named.loopback named.localhost named.ca }.sort
    end

    it "sets the rndc keygen command" do
      @node[attr_ns]['rndc_keygen'].must_equal "rndc-confgen -a"
    end
  end

  describe "for ubuntu platform version 12.04" do
    let(:ohai_data) do
      { :platform => "ubuntu", :platform_version => "12.04" }
    end

    it "sets the package list" do
      @node[attr_ns]['packages'].sort.must_equal %w{ bind9 bind9utils }.sort
    end

    it "sets the var directory" do
      @node[attr_ns]['vardir'].must_equal "/var/cache/bind"
    end

    it "sets the sysconf directory" do
      @node[attr_ns]['sysconfdir'].must_equal "/etc/bind"
    end
  end

  describe "for a virtual centos 6.2 host" do
    let(:ohai_data) do
      { :platform => "centos", :platform_version => "6.2", 
        :virtualization => {
          :role => "guest"
        }
      }

      it "sets the rndc keygen command" do
        @node[attr_ns]['rndc_keygen'].must_equal "rndc-confgen -a -r /dev/urandom"
      end
    end
  end
end
