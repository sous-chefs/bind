domain = input('domain')
host_string = input('host_string')
chroot = input('chroot')
views = input('views')
ip_addr = interfaces.ipv4_address

case os.family
when 'debian'
  chroot_cmd = '-t /var/bind9/chroot'
  named_cmd = if os.name == 'debian' && os.release.to_i == 10
                '/usr/sbin/named -u bind'
              else
                '/usr/sbin/named -f -u bind'
              end
when 'redhat', 'fedora'
  named_cmd = '/usr/sbin/named -u named -c /etc/named.conf'
  chroot_cmd = '-t /var/named/chroot'
end

control 'default' do
  describe port 53 do
    it { should be_listening }
    its('processes') { should include 'named' }
  end

  describe processes 'named' do
    if chroot
      its('commands') { should include "#{named_cmd} #{chroot_cmd}" }
    else
      its('commands') { should include named_cmd }
    end
  end

  describe command 'rndc reload' do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "server reload successful\n" }
  end

  describe command "host #{domain} 127.0.0.1" do
    its('exit_status') { should eq 0 }
    its('stdout') { should include host_string }
  end

  if views
    describe command "dig +short sub.example.org txt @#{ip_addr}" do
      its('exit_status') { should eq 0 }
      its('stdout') { should include '"external"' }
    end

    describe command 'dig +short sub.example.org txt @127.0.0.1' do
      its('exit_status') { should eq 0 }
      its('stdout') { should include '"internal"' }
    end
  end
end
