#!/bin/bash

. test/teardown.sh

mkdir -p /tmp/inkfish/test-ldap/data
chmod 644 test/slapd.conf

/usr/sbin/slapd -f test/slapd.conf -h ldap://localhost:13389
sleep 2
ldapadd -h localhost:13389 -D cn=admin,dc=example,dc=com -w test -f test/test-data.ldif

export MIX_ENV=test
mix ecto.create
mix ecto.migrate
(cd apps/inkfish && mix run test/test_seeds.exs)
