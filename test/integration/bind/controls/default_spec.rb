domain = input('domain')
host_string = input('host_string')

control 'default' do
  describe port 53 do
    it { should be_listening }
    its('processes') { should include 'named' }
  end

  describe command 'rndc reload' do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "server reload successful\n" }
  end

  describe command "host #{domain} 127.0.0.1" do
    its('exit_status') { should eq 0 }
    its('stdout') { should include host_string }
  end
end
