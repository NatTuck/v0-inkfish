#!/bin/bash

docker image rm -f systems:v1
docker image build . -t systems:v1 --no-cache
