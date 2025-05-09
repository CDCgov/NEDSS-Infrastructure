#!/bin/bash

# define some functions used in lots of scripting, need to remove duplication
# log debug debug_message log_debug  pause_step step_pause load_defaults update_defaults resolve_secret prompt_for_value check_for_placeholders
source "$(dirname "$0")/../../common_functions.sh"

#INSTALL_DIR=~/nbs_install
#NOOP=0
# Default file for storing selected values and entered credentials
#DEFAULTS_FILE="`pwd`/nbs_defaults.sh"
DEBUG=1
STEP=1
SLEEP_TIME=60
# must edit with each release or prompt and save

# Function to load saved defaults
#load_defaults() {
#    if [ -f "$DEFAULTS_FILE" ]; then
#        source "$DEFAULTS_FILE"
#    fi
#}

#update_defaults() {
#    local var_name=$1
#    local var_value=$2
#    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
#        #sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
#        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
#    else
#        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
#    fi
#}

load_defaults;

# Prompt for missing values with defaults
#read -p "Please enter Helm version [${HELM_VER_DEFAULT}]: " input_helm_ver
#HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
#update_defaults HELM_VER $HELM_VER

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
#
#
#echo "what is the domain you will be using?"
#read TMP_DOMAIN

#TMP_DOMAIN=site.example.com

#echo "TMP_DOMAIN=${TMP_DOMAIN}"

remove_dns() 
{
  local TMP_HOST="$1"

  # Try to resolve the TMP_HOST to an IP address.
  local ip_address=$(dig +short "$TMP_HOST")

  # If the IP address is empty, the TMP_HOST does not resolve.
  if [[ ! -z "$ip_address" ]]; then
    echo "WARNING: now entry for $TMP_HOST is stale"
    #exit 1
  fi
  echo "manually remove dns entries for  ${TMP_HOST}"
}


helm_remove()
{
    helm list
    TMP_CONTAINER=$1
    echo "removing ${TMP_CONTAINER}"
    echo "hit return to continue"
    read junk
    helm uninstall ${TMP_CONTAINER} 
}

# remove pods in reverse of install
echo "pods running"
kubectl get pods

echo "helm charts installed"
helm list

helm_remove nnd-service
helm_remove person-reporting-service
helm_remove post-processing-reporting-service
helm_remove ldfdata-reporting-service
helm_remove investigation-reporting-service
helm_remove organization-reporting-service
helm_remove observation-reporting-service
helm_remove kafka-connect-sink
helm_remove debezium
helm_remove liquibase

helm_remove dataingestion
#helm_remove dataingestion-service

helm_remove nbs-gateway 
helm_remove nifi 
helm_remove modernization-api 
helm_remove page-builder-api 
helm_remove elasticsearch 
helm_remove keycloak

#remove_dns app-classic.${SITE_NAME}.${EXAMPLE_DOMAIN};
remove_dns app.${SITE_NAME}.${EXAMPLE_DOMAIN};
remove_dns nifi.${SITE_NAME}.${EXAMPLE_DOMAIN};

# this will remove nlb and ingress routing 
helm list --namespace ingress-nginx        

echo "removing ingress-nginx"
echo "hit return to continue"
read junk
helm uninstall  --namespace ingress-nginx ingress-nginx

exit 0

