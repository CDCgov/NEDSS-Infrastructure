#!/bin/bash

# must edit with each release or prompt and save
HELM_VER=v1.0.0
echo "edit line 4 and comment out exit, then rerun"
exit 1

INGRESS_VER=4.7.2
INSTALL_DIR=~/nbs_install
HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}
cd ${HELM_DIR}/charts

#
# nginx ingress
#
helm upgrade --install ingress-nginx ingress-nginx --repo
https://kubernetes.github.io/ingress-nginx -f nginx-ingress/values.yaml --namespace ingress-nginx --create-namespace --version ${INGRESS_VER}

kubectl get po -n=ingress-nginx
echo "control-c to exit this status"
kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller


exit 0

cd ${HELM_DIR}/k8-manifests/

cp -p cluster-issuer-prod.yaml cluster-issuer-prod.yaml.orig

echo "change email address"
echo "hit return to continue"
read junk

vi cluster-issuer-prod.yaml

kubectl apply -f cluster-issuer-prod.yaml

echo "check status, should be ready"
echo "running, kubectl get clusterissuer"
kubectl get clusterissuer
