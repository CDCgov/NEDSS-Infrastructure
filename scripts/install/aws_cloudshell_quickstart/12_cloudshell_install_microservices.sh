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

# define some functions used in lots of scripting, need to remove duplication
# log debug debug_message pause_step load_defaults update_defaults resolve_secret prompt_for_value check_for_placeholders
source "$(dirname "$0")/../../common_functions.sh"

#HELM_VER=v7.9.2
#INSTALL_DIR=~/nbs_install
#DEFAULTS_FILE="`pwd`/nbs_defaults.sh"
SLEEP_TIME=60
#SLEEP_TIME=10
#DEBUG=0
#STEP=0
#NOOP=0

KC_NAMESPACE=default
DEFAULT_NAMESPACE=default

# Function to load saved defaults
# moved to common_functions
#load_defaults() {
#    if [ -f "$DEFAULTS_FILE" ]; then
#        source "$DEFAULTS_FILE"
#    fi
#}

# Update defaults safely
# moved to common_functions
#update_defaults() {
#    local var_name=$1
#    local var_value=$2
#    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
#        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
#    else
#        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
#    fi
#}

# Parsing command-line options
BACKUP=0
DATE_SUFFIX=$(date +%Y%m%d%H%M%S)

while getopts "dsb" opt; do
  case $opt in
    d)
      DEBUG=1
      ;;
    s)
      STEP=1
      ;;
    b)
      BACKUP=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

load_defaults;

# moved to common_functions
#function debug_message() {
#    if [[ $DEBUG -eq 1 ]]; then
#        echo "DEBUG: $1"
#    fi
#}

# moved to common_functions
#function pause_step() {
#    if [[ $STEP -eq 1 ]]; then
#        read -p "Press [Enter] to continue..."
#    fi
#}

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

    local values_file="./$path/values-${SITE_NAME}.yaml"
    check_for_placeholders_exit "$values_file"
    check_for_examples_exit "$values_file"

    if helm list -n ${namespace} --short | grep -q "^${name}$"; then
        debug_message "$name is already installed, checking for updates..."

        if [[ "$BACKUP" -eq 1 ]]; then
            debug_message "Backing up Helm manifests and values for $name"
            helm get manifest $name -n $namespace > "$path/${name}.manifest.${DATE_SUFFIX}.yaml"
            helm get values $name -n $namespace --all > "$path/${name}.values.${DATE_SUFFIX}.yaml"
        fi

        helm upgrade $name -n ${namespace} -f "$values_file" "$path"
    else
        debug_message "Installing $name"
        helm install $name -n ${namespace} --create-namespace -f "$values_file" "$path"
    fi

    echo "Sleeping for ${SLEEP_TIME} seconds"
    sleep ${SLEEP_TIME}
    echo

    pause_step
}

cd ${HELM_DIR}/charts

check_dns app.${SITE_NAME}.${EXAMPLE_DOMAIN};
check_dns nifi.${SITE_NAME}.${EXAMPLE_DOMAIN};
#check_dns dataingestion.${SITE_NAME}.${EXAMPLE_DOMAIN};
check_dns data.${SITE_NAME}.${EXAMPLE_DOMAIN};
echo not running "check_dns app-classic.${SITE_NAME}.${EXAMPLE_DOMAIN};"

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
# cluster autoscaler

helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler -f ./cluster-autoscaler/values-${SITE_NAME}.yaml --namespace kube-system
# not sure autoscaler/cluster-autoscaler makes sense???
# maybe helm_safe_install cluster-autoscaler cluster-autoscaler kube-system
# helm_safe_install cluster-autoscaler cluster-autoscaler kube-system
#helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler -f ./cluster-autoscaler/values.yaml --namespace kube-system

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

read -p "Ready to run liquibase? (it now needs to run before DI) [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading liquibase pod"
    helm_safe_install liquibase liquibase ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "liquibase loaded"
else
    echo "liquibase skipped."
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

echo "ready to start RTI install process"
read -p "Have the data-processing-service database requirements been implemented? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading data-processing-service pod"
    helm_safe_install data-processing-service data-processing-service ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "data-processing-service loaded"
else
    echo "data-processing-service skipped."
fi

echo "ready to start RTR install process"
read -p "Have the database prep steps been done for debezium (CDC, etc)? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading debezium pod"
    helm_safe_install debezium debezium ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "debezium loaded"
else
    echo "debezium skipped."
fi

read -p "Have the database prep steps been done for kafka-connect-sink (CDC, etc)? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading kafka-connect-sink pod"
    helm_safe_install kafka-connect-sink kafka-connect-sink ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "kafka-connect-sink loaded"
else
    echo "kafka-connect-sink skipped."
fi

kubectl get pods 

read -p "Have the all RTR required containers started correctly? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading rtr containers"
    helm_safe_install observation-reporting-service observation-reporting-service ${DEFAULT_NAMESPACE}
    helm_safe_install organization-reporting-service organization-reporting-service ${DEFAULT_NAMESPACE}
    helm_safe_install investigation-reporting-service investigation-reporting-service ${DEFAULT_NAMESPACE}
    helm_safe_install ldfdata-reporting-service ldfdata-reporting-service ${DEFAULT_NAMESPACE}
    helm_safe_install post-processing-reporting-service post-processing-reporting-service ${DEFAULT_NAMESPACE}
    helm_safe_install person-reporting-service person-reporting-service ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "rtr containers loaded"
else
    echo "rtr containers skipped."
fi
exit 0

kubectl get pods 

read -p "Have the database prep steps been done for nnd-service (CDC, etc)? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_message "loading nnd-service pod"
    helm_safe_install nnd-service nnd-service ${DEFAULT_NAMESPACE}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to load"
    fi
    echo "nnd-service loaded"
else
    echo "nnd-service skipped."
fi

kubectl get pods 
