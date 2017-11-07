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
