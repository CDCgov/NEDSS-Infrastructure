#!/bin/bash

# Description:
# This script automates the installation and configuration of various microservices using Helm.
# It manages Helm chart installations for services like Elasticsearch, NiFi, and several APIs,
# ensuring that each component is properly configured and deployed within a specified Kubernetes environment.
# It supports idempotent operation, meaning it can safely be re-run without unintended side effects.

# Requirements:
# - Helm 3 installed and configured
# - Kubernetes cluster access with configured kubectl
# - Internet access for resolving DNS and fetching Helm charts
# - dig command available for DNS checks
# - Bash 4.0 or newer

# Usage:
# ./this_script.sh [options]
# Options:
#  -d : Enable debug mode for verbose output
#  -s : Enable step mode to proceed through the script interactively

HELM_VER=v7.5.0
INSTALL_DIR=~/nbs_install
DEFAULTS_FILE="nbs_defaults.sh"
SLEEP_TIME=60
#SLEEP_TIME=10
DEBUG=0
STEP=0
NOOP=0
KC_NAMESPACE=default
DEFAULT_NAMESPACE=default

# Function to load saved defaults
load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
    fi
}

# Update defaults safely
update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}

# Parsing command-line options
while getopts "ds" opt; do
  case $opt in
    d)
      DEBUG=1
      ;;
    s)
      STEP=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

load_defaults;

function debug_message() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "DEBUG: $1"
    fi
}

function pause_step() {
    if [[ $STEP -eq 1 ]]; then
        read -p "Press [Enter] to continue..."
    fi
}

# Only update if input changes
read -p "Please enter Helm version [${HELM_VER_DEFAULT}]: " input_helm_ver
if [ "$input_helm_ver" != "$HELM_VER_DEFAULT" ]; then
    HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
    update_defaults HELM_VER $HELM_VER
fi

read -p "Please enter installation directory [${INSTALL_DIR_DEFAULT}]: " input_install_dir
if [ "$input_install_dir" != "$INSTALL_DIR_DEFAULT" ]; then
    INSTALL_DIR=${input_install_dir:-$INSTALL_DIR_DEFAULT}
    update_defaults INSTALL_DIR $INSTALL_DIR
fi

# Prompts for additional information
read -p "Please enter the site name e.g. fts3 [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
# read -p "Enter Image Name [$IMAGE_NAME_DEFAULT]: " IMAGE_NAME && IMAGE_NAME=${IMAGE_NAME:-$IMAGE_NAME_DEFAULT}
update_defaults "SITE_NAME" "$SITE_NAME"

read -p "Please enter domain name e.g. nbspreview.com [${EXAMPLE_DOMAIN_DEFAULT}]: " EXAMPLE_DOMAIN  && EXAMPLE_DOMAIN=${EXAMPLE_DOMAIN:-$EXAMPLE_DOMAIN_DEFAULT}
update_defaults "EXAMPLE_DOMAIN" "$EXAMPLE_DOMAIN"


HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}
cd ${INSTALL_DIR}

function check_dns() {
  local TMP_HOST="$1"
  debug_message "Checking DNS for ${TMP_HOST}"
  local ip_address=$(dig +short "$TMP_HOST")
  if [[ -z "$ip_address" ]]; then
    echo "ERROR: $TMP_HOST does not resolve!!"
    exit 1
  fi
}

function helm_safe_install() {
    local name=$1
    local path=$2
    local namespace=$3
    echo
    echo "Installing or upgrading $name"
    #if ! helm list --short | grep -q "^${name}$"; then
    if ! helm list -n ${namespace} --short | grep -q "^${name}$"; then
        debug_message "Installing $name"
        helm install $name -n ${namespace} --create-namespace -f ./$path/values-${SITE_NAME}.yaml $path
        echo "Sleeping for ${SLEEP_TIME} seconds"
        sleep ${SLEEP_TIME}
    else
        debug_message "$name is already installed, checking for updates..."
        helm upgrade $name -n ${namespace} -f ./$path/values-${SITE_NAME}.yaml $path
        echo "Sleeping for ${SLEEP_TIME} seconds"
        sleep ${SLEEP_TIME}
    fi
    # add a blank line
    echo

    pause_step

}

cd ${HELM_DIR}/charts

check_dns app-classic.${SITE_NAME}.${EXAMPLE_DOMAIN};
check_dns app.${SITE_NAME}.${EXAMPLE_DOMAIN};
check_dns nifi.${SITE_NAME}.${EXAMPLE_DOMAIN};
check_dns dataingestion.${SITE_NAME}.${EXAMPLE_DOMAIN};

#####################################################################
# linkerd/mtls
echo "check if namespace is annotated for linkerd/mtls"
echo " probably not enabled yet, will be blank"
echo "hit return to continue"
read junk
kubectl get namespace ${DEFAULT_NAMESPACE} -o=jsonpath='{.metadata.annotations}'

echo "annotating ${DEFAULT_NAMESPACE} namespace to enable linkerd mtls"
echo "hit return to continue"
read junk
kubectl annotate namespace ${DEFAULT_NAMESPACE} "linkerd.io/inject=enabled"

echo "check if namespace is annotated for linkerd/mtls"
echo " should show enabled"
echo "hit return to continue"
read junk
kubectl get namespace ${DEFAULT_NAMESPACE} -o=jsonpath='{.metadata.annotations}'
echo


#####################################################################

helm_safe_install elasticsearch elasticsearch-efs ${DEFAULT_NAMESPACE}

read -p "Has the keycloak database been created? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading keycloak pod"
    helm_safe_install keycloak keycloak ${KC_NAMESPACE}
    # need a name space
    #helm install keycloak -n keycloak --create-namespace -f ./keycloak/values-${SITE_NAME}.yaml keycloak
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "keycloak loaded"
    echo "you have 300 seconds to upload to the persistent volume for new themes"
    echo 
else
    echo "keycloak skipped."
fi

kubectl get pods -n ${DEFAULT_NAMESPACE}

#########################################################################
# this portion should be modified to not repeat logic
read -p "are you are using keycloak for auth(make sure it is ready after initializing)? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "has keycloak imported required realm and modified client secrets reflected created? [y/N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        helm_safe_install page-builder-api page-builder-api ${DEFAULT_NAMESPACE}
        helm_safe_install modernization-api modernization-api ${DEFAULT_NAMESPACE}
        helm_safe_install nifi nifi-efs ${DEFAULT_NAMESPACE}
        helm_safe_install nbs-gateway nbs-gateway ${DEFAULT_NAMESPACE}
    else
        echo "WARNING: microservices install skipped. unfinished" 
        exit 1
    fi
else
    echo "NOTICE: installing other microservices without keycloak integrations"
    helm_safe_install page-builder-api page-builder-api ${DEFAULT_NAMESPACE}
    helm_safe_install modernization-api modernization-api ${DEFAULT_NAMESPACE}
    helm_safe_install nifi nifi-efs ${DEFAULT_NAMESPACE}
    helm_safe_install nbs-gateway nbs-gateway ${DEFAULT_NAMESPACE}
fi 


read -p "Has the dataingestion database been created? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading dataingestion pod"
    helm_safe_install dataingestion dataingestion-service ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "dataingestion loaded"
else
    echo "dataingestion skipped."
fi

kubectl get pods 

exit 0


