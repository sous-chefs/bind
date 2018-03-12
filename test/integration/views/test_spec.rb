# frozen_string_literal: true
describe port(53) do
  it { should be_listening }
  its('processes') { should include 'named' }
end

describe command('rndc reload') do
  its('exit_status') { should eq 0 }
  its('stdout') { should eq "server reload successful\n" }
end

describe bash(%q(dig +short sub.example.com txt @$(ip addr show dev eth0 | awk '/inet / { split($2, ip, "/"); print ip[1] }'))) do
  its('exit_status') { should eq 0 }
  its('stdout') { should include '"external"' }
end

describe bash('dig +short sub.example.com txt @127.0.0.1') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include '"internal"' }
end
