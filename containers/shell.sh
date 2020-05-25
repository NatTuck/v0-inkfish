#!/bin/bash
docker run --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
	-it systems:v1 bash 
