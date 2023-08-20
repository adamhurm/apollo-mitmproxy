#!/bin/bash

CURRENT_DIR=$PWD
MITMPROXY_VERSION=10.0.0
MITMPROXY_WHEEL=mitmproxy-$MITMPROXY_VERSION-py3-none-any.whl
MITMPROXY_URL=https://downloads.mitmproxy.org/$MITMPROXY_VERSION/$MITMPROXY_WHEEL

# -- Docker --
cd $CURRENT_DIR/docker
docker build -t adamhurm/apollo-mitmproxy --build-arg MITMPROXY_WHEEL=$MITMPROXY_WHEEL . 
echo 'ℹ️  Built apollo-mitmproxy image'

#docker save -o apollo-mitmproxy.tar adamhurm/apollo-mitmproxy:latest
#echo 'ℹ️  Saved docker image to apollo-mitmproxy.tar'
#echo 'ℹ️  Running docker compose'
#docker compose up


# -- K8s --
cd $CURRENT_DIR/k8s
echo 'ℹ️  Applying k8s manifests'
kubectl apply -f deployment.yml
kubectl apply -f service.yml

#kubectl apply -f nip.io/ingress.yaml
#kubectl apply -f nip.io/service.yaml
