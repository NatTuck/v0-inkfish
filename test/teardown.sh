#!/bin/bash

PIDF=/tmp/inkfish/test-ldap/slapd.pid

if [[ -e $PIDF ]]
then
    kill $(cat $PIDF)
    sleep 2
fi

if [[ -d /tmp/inkfish/test-ldap ]]
then
    rm -rf /tmp/inkfish/test-ldap
fi

export MIX_ENV=test
mix ecto.drop

