# frozen_string_literal: true

describe port(53) do
  it { should be_listening }
  its('processes') { should include 'named' }
end

describe command('host www.google.com 127.0.0.1') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'www.google.com has address ' }
end

describe file('/tmp/query.log') do
  its('content') { should match(/^client 127.0.0.1#\d+: query: www.google.com/) }
end

describe file('/tmp/general.log') do
  its('content') { should include 'zone example.com/IN: loaded serial 2002022401' }
end
