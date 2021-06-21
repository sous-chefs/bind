
require 'spec_helper'

describe 'adding a new channel' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '8', step_into: %w(
        bind_config
        bind_logging_channel
        bind_logging_category
      )
    ).converge('bind_test::spec_basic_logging_channel')
  end

  it 'adds a syslog channel' do
    stanza = '  channel syslog {
    syslog mail;
    severity info;
    print-category yes;
    print-severity yes;
    print-time yes;
  };'
    expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
      expect(content).to include stanza
    }
  end

  it 'adds a stderr channel with default severity and print options' do
    stanza = '  channel stderr {
    stderr;
    severity dynamic;
  };'
    expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
      expect(content).to include stanza
    }
  end

  it 'adds a file channel with custom rotation and size options' do
    stanza = '  channel example-file {
    file "test.log" versions 10 size unlimited;'

    expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
      expect(content).to include stanza
    }
  end

  it 'adds a file channel with out custom options' do
    stanza = '  channel basic-file {
    file "basic.log";'

    expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
      expect(content).to include stanza
    }
  end

  it 'adds a category' do
    stanza = '  category default { syslog; stderr; };'
    expect(chef_run).to render_file('/etc/named/named.options').with_content { |content|
      expect(content).to include stanza
    }
  end
end
