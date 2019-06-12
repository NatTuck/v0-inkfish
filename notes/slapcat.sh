#!/bin/bash
ldapsearch -h localhost:3389 -D cn=admin,dc=example,dc=com -w test -b ou=people,dc=example,dc=com
