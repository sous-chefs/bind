# frozen_string_literal: true
require 'spec_helper'

describe 'adding primary zones' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: %w(bind_config bind_primary_zone_template)
    ).converge('bind_test::spec_primary_zone_template')
  end

  context 'simple mostly empty zone' do
    it 'uses the custom resource' do
      expect(chef_run).to create_bind_primary_zone_template('empty.example.com')
    end

    it 'will populate basic zone data' do
      expect(chef_run).to render_file('/var/named/primary/db.empty.example.com').with_content { |content|
        expect(content).to match(/^@\s+IN\s+SOA\s+localhost\.\s+hostmaster\.localhost\.\s+\(/)
      }
    end

    it 'will place the config in the named config' do
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to include 'zone "empty.example.com" IN {'
        expect(content).to include 'file "primary/db.empty.example.com";'
      }
    end

    it 'can add options to a zone' do
      stanza = <<~EOF
        zone "empty.example.com" IN {
          type master;
          file "primary/db.empty.example.com";
          check-names warn;
        };
      EOF
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to include stanza
      }
    end
  end

  context 'zone with custom data' do
    it 'uses the custom resource' do
      expect(chef_run).to create_bind_primary_zone_template('custom.example.com')
    end

    it 'will populate basic zone data' do
      expect(chef_run).to render_file('/var/named/primary/db.custom.example.com').with_content { |content|
        expect(content).to match(/^@\s+IN\s+SOA\s+ns1\.example\.com\.\s+hostmaster\.example\.com\.\s+\(/)
        expect(content).to match(/^\s+IN\s+NS\s+ns1\.example\.com\.$/)
        expect(content).to include '$TTL 200'
        expect(content).to include '100 ; Serial'
        expect(content).to match(/^www\s+20\s+IN\s+A\s+10.5.0.1$/)
      }
    end

    it 'will place the config in the named config' do
      expect(chef_run).to render_file('/etc/named.conf').with_content { |content|
        expect(content).to include 'zone "custom.example.com" IN {'
        expect(content).to include 'file "primary/db.custom.example.com";'
      }
    end
  end
end

describe 'zones with managed serial numbers' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.3.1611', step_into: %w(bind_config bind_primary_zone_template)
    ) do |node|
      node.normal['bind']['zone']['custom.example.com']['serial'] = '100'
      node.normal['bind']['zone']['custom.example.com']['hash'] = '100'
      node.normal['bind']['zone']['nochange.example.com'].tap do |zone|
        zone['serial'] = '999'
        zone['hash'] = 'ba764135482976fa2c1953075a8077f5d5a951052133456f83c1084c8bfcf173'
      end
    end
  end

  context 'a new empty zone' do
    it 'has no serial number persisted to the node' do
      attribute = chef_run.node.normal['bind']['zone']['empty.example.com']
      expect(attribute.key?('serial')).to be false
    end

    it 'persists a serial number to the node' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      attribute = chef_run.node.normal
      expect(attribute['bind']['zone']['empty.example.com'].empty?).to be false
      expect(attribute['bind']['zone']['empty.example.com']['serial']).to eq '1'
    end

    it 'persists a hash code to the node object' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      attribute = chef_run.node.normal
      hash_code = attribute['bind']['zone']['empty.example.com']['hash']
      expect(hash_code).to eq '54fb331da7106128dacb7162f72493684c46e5cbd12f9d830ec87d07cbbf3e83'
    end
  end

  context 'a zone with no changes' do
    it 'does not change the persisted serial number' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      attribute = chef_run.node.normal
      expect(attribute['bind']['zone']['nochange.example.com']['serial']).to eq '999'
    end

    it 'does not change the persisted hash code' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      attribute = chef_run.node.normal
      hash_code = attribute['bind']['zone']['nochange.example.com']['hash']
      expect(hash_code).to eq 'ba764135482976fa2c1953075a8077f5d5a951052133456f83c1084c8bfcf173'
    end
  end

  context 'a zone where the hash value has changed' do
    it 'changes the serial number persisted' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      attribute = chef_run.node.normal['bind']['zone']['custom.example.com']
      expect(attribute['serial']).to eq '101'
    end

    it 'changes the serial number when managed' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      attribute = chef_run.node.normal['bind']['zone']['nochange.example.com']
      expect(attribute['serial']).to eq '999'
    end

    it 'uses the custom resource' do
      chef_run.converge('bind_test::spec_primary_zone_template_manage_serial')
      expect(chef_run).to render_file('/var/named/primary/db.nochange.example.com')
      expect(chef_run).to create_bind_primary_zone_template('nochange.example.com')
      expect(chef_run).to create_bind_primary_zone_template('custom.example.com')
    end
  end
end
