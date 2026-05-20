domain = input('domain')
host_string = input('host_string')
chroot = input('chroot')
views = input('views')
logging = input('logging')
linked = input('linked')
ip_addr = interfaces.ipv4_address

case os.family
when 'debian'
  chroot_cmd = '-t /var/bind9/chroot'
  named_cmd = %r{/usr/sbin/named (?:-f )?-u bind}
when 'redhat', 'fedora'
  named_cmd = %r{/usr/sbin/named -u named -c /etc/named\.conf}
  chroot_cmd = '-t /var/named/chroot'
end

control 'default' do
  describe port 53 do
    it { should be_listening }
    its('processes') { should include 'named' }
  end

  describe processes 'named' do
    subject { processes('named').commands.join("\n") }

    if chroot
      it { should match(/#{named_cmd.source} #{Regexp.escape(chroot_cmd)}/) }
    else
      it { should match(named_cmd) }
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
    describe command "dig google.com @#{ip_addr}" do
      its('exit_status') { should eq 0 }
      its('stdout') { should match /WARNING: recursion requested but not available/ }
    end

    describe command "dig +short sub.example.org txt @#{ip_addr}" do
      its('exit_status') { should eq 0 }
      its('stdout') { should include '"external"' }
    end

    describe command 'dig +short sub.example.org txt @127.0.0.1' do
      its('exit_status') { should eq 0 }
      its('stdout') { should include '"internal"' }
    end
  end

  if logging
    queried_domain = Regexp.escape(domain)

    describe file '/srv/query.log' do
      its('content') { should match(/^client.*127.0.0.1#\d+.*query: #{queried_domain}/) }
    end

    describe file '/srv/general.log' do
      its('content') { should include 'zone example.org/IN: loaded serial 2002022401' }
    end
  end

  if linked
    describe command "host ns1.example.net #{ip_addr}" do
      its('exit_status') { should eq 0 }
      its('stdout') { should include 'ns1.example.net has address 1.1.1.1' }
    end
  end
end
