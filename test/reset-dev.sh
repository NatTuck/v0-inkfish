#!/bin/bash

ldapdelete -x -r -D cn=admin,dc=example,dc=com -w iukeefei8oFu \
    "ou=people,dc=example,dc=com"

ldapadd -x -D cn=admin,dc=example,dc=com -w iukeefei8oFu -f test/test-data.ldif

