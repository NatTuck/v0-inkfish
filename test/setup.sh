#!/bin/bash

mkdir -p /tmp/test-ldap
chmod 644 test/slapd.conf

slapd -f test/slapd.conf -h ldap://localhost:3389
sleep 2
ldapadd -h localhost:3389 -D cn=admin,dc=example,dc=com -w test -f test/test-data.ldif
