#!/bin/bash

ldapadd -h localhost -p 389 -D cn=admin,dc=test,dc=com -w test -f test/
