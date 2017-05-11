#!/bin/bash -v
apt-get update -y
apt-get install -y golang > /tmp/nginx.log

mkdir ~/go

export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
