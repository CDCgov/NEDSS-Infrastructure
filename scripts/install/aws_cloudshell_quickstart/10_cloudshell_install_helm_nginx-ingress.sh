#!/bin/bash

# must edit with each release or prompt and save


# Default file for storing selected values and entered credentials
HELM_VER=v7.3.3
echo "edit line 4 and comment out exit, then rerun"
exit 1

INGRESS_VER=4.7.2
INSTALL_DIR=~/nbs_install

DEFAULTS_FILE="nbs_defaults.sh"

# Function to load saved defaults
load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
    fi
}

update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}


read -p "Please enter NBS Helm release version [${HELM_VER_DEFAULT}]: " HELM_VER  && HELM_VER=${HELM_VER:-$HELM_VER_DEFAULT}
update_defaults "HELM_VER" "$HELM_VER"

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
