#!/usr/bin/env bats

@test 'bind is running' {
  pgrep named || pgrep bind9
}

@test 'rndc can reload the server' {
  /usr/sbin/rndc reload
}

@test 'something is listening on udp or tcp 53' {
  ss -lun | grep ':53' || ss -ltn | grep ':53'
}
