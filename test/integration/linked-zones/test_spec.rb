# frozen_string_literal: true
describe port(53) do
  it { should be_listening }
  its('processes') { should include 'named' }
end

describe command('rndc reload') do
  its('exit_status') { should eq 0 }
  its('stdout') { should eq "server reload successful\n" }
end

describe bash(%q(host ns1.example.net $(ip -4 -br addr | grep -oP "(10|172)(.\d{1,2}){3}"))) do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'ns1.example.net has address 1.1.1.1' }
end

describe command('host ns1.example.net 127.0.0.1') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'ns1.example.net has address 1.1.1.1' }
end
