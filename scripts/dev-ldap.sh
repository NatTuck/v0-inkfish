#!/bin/bash

LDIR=/tmp/inkfish/dev-ldap
PIDF=$LDIR/slapd.pid

if [[ -e $PIDF ]]
then
    kill $(cat $PIDF)
    sleep 2
fi

if [[ -d $LDIR ]]
then
    rm -rf $LDIR
fi

mkdir -p $LDIR/data
chmod 644 ./notes/dev-slapd.conf

/usr/sbin/slapd -f ./notes/dev-slapd.conf -h ldap://localhost:3389
sleep 2
ldapadd -h localhost:3389 -D cn=admin,dc=example,dc=com -w test -f ./test/test-data.ldif
