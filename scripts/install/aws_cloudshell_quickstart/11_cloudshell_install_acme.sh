#!/bin/bash

HELM_VER=v7.5.0
#echo "edit line 4 and comment out exit, then rerun"
#exit 1
INSTALL_DIR=~/nbs_install
DEBUG=1
STEP=1
NOOP=0

# must edit with each release or prompt and save
# Default file for storing selected values and entered credentials
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
        #sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}

load_defaults;

# Prompt for missing values with defaults
read -p "Please enter Helm version [${HELM_VER_DEFAULT}]: " input_helm_ver
HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
update_defaults HELM_VER $HELM_VER

read -p "Please enter installation directory [${INSTALL_DIR_DEFAULT}]: " input_install_dir
INSTALL_DIR=${input_install_dir:-$INSTALL_DIR_DEFAULT}
update_defaults INSTALL_DIR $INSTALL_DIR

# Read necessary input from user
read -p "Please enter the site name [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
read -p "Please enter domain name [${EXAMPLE_DOMAIN_DEFAULT}]: " EXAMPLE_DOMAIN  && EXAMPLE_DOMAIN=${EXAMPLE_DOMAIN:-$EXAMPLE_DOMAIN_DEFAULT}
# Update defaults
update_defaults "SITE_NAME" "$SITE_NAME"
update_defaults "EXAMPLE_DOMAIN" "$EXAMPLE_DOMAIN"

# Proceed with the rest of the script
HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}

cd ${HELM_DIR}/k8-manifests

cp -p cluster-issuer-prod.yaml cluster-issuer-prod.yaml.orig

echo "change email address"
echo "hit return to continue"
read junk

vi cluster-issuer-prod-${SITE_NAME}.yaml

echo running kubectl apply -f cluster-issuer-prod-${SITE_NAME}.yaml

kubectl apply -f cluster-issuer-prod-${SITE_NAME}.yaml

echo "sleeping for 30 seconds to allow provisioning to complete"
sleep 30

echo "check status, should be ready"
echo "running, kubectl get clusterissuer"
kubectl get clusterissuer

echo "check certs, should not have any listed until microservices added"
echo "running, kubectl get certificates"
kubectl get certificates -A
