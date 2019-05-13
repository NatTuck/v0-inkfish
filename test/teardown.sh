#!/bin/bash

PIDF=/test-ldap/slapd.pid

if [[ -e $PIDF ]]
then
    kill $(cat $PIDF)
    sleep 2
fi

if [[ -d /tmp/test-ldap ]]
then
    rm -rf /tmp/test-ldap
fi

export MIX_ENV=test
mix ecto.drop

