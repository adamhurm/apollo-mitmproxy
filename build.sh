#!/bin/bash

CURRENT_DIR=$PWD

# -- Docker --
cd $CURRENT_DIR/docker
docker build -t adamhurm/apollo-mitmproxy . 
echo 'ℹ️  Built apollo-mitmproxy image'

#docker save -o apollo-mitmproxy.tar adamhurm/apollo-mitmproxy:latest
#echo 'ℹ️  Saved docker image to apollo-mitmproxy.tar'
#echo 'ℹ️  Running docker compose'
#docker compose up


# -- K8s --
cd $CURRENT_DIR
echo 'ℹ️  Applying k8s manifests'
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml

#kubectl apply -f k8s/nip.io/ingress.yaml
#kubectl apply -f k8s/nip.io/service.yaml
