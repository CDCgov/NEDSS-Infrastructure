#!/bin/bash

# must edit with each release or prompt and save
HELM_VER=v1.0.0
echo "edit line 4 and comment out exit, then rerun"
exit 1
INSTALL_DIR=~/nbs_install

HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}

cd ${HELM_DIR}/k8-manifests

cp -p cluster-issuer-prod.yaml cluster-issuer-prod.yaml.orig

echo "change email address"
echo "hit return to continue"
read junk

vi cluster-issuer-prod.yaml

kubectl apply -f cluster-issuer-prod.yaml

echo "check status, should be ready"
echo "running, kubectl get clusterissuer"
kubectl get clusterissuer
