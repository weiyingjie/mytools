#!/bin/bash

#/var/cache/apt/archives

#apt-get install apt-rdepends -y

readonly TARGET=$1
for pkg in $(apt-rdepends ${TARGET} | grep -v "^ " | grep -v "^libc-dev$"); do
	apt-get download ${pkg}:amd64 | apt-get download ${pkg}:all
done
