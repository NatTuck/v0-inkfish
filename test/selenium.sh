#!/bin/bash

TMP=/var/tmp/selenium
mkdir -p $TMP/bin

JAR=selenium-server-standalone-4.0.0-alpha-2.jar
URL=https://selenium-release.storage.googleapis.com/4.0/$JAR
SERVER=$TMP/$JAR

if [[ ! -e $SERVER ]];
then
    wget -O $SERVER $URL
fi

DRIVER_TGZ=geckodriver-v0.26.0-linux64.tar.gz
DRIVER_URL=https://github.com/mozilla/geckodriver/releases/download/v0.26.0/$DRIVER_TGZ
DRIVER_DL=$TMP/$DRIVER_TGZ
DRIVER=$TMP/bin/geckodriver

if [[ ! -e $DRIVER_DL ]];
then
    wget -O $DRIVER_DL $DRIVER_URL
fi

if [[ ! -e $DRIVER ]];
then
    (cd $TMP/bin && tar xzvf $DRIVER_DL)
fi

export PATH="$TMP/bin:$PATH"
java -jar $SERVER
