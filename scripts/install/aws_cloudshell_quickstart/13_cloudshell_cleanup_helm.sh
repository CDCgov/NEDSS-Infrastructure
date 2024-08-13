#!/bin/bash
#HELM_VER=v7.5.0
#exit 1
INSTALL_DIR=~/nbs_install
DEBUG=1
STEP=1
NOOP=0
SLEEP_TIME=60
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


# remove pods in reverse of install
echo "pods running"
kubectl get pods

echo "helm charts installed"
helm list
echo "removing dataingestion"
echo "hit return to continue"
read junk
#helm uninstall dataingestion-service
helm uninstall dataingestion


helm list
echo "removing nbs-gateway"
echo "hit return to continue"
read junk
helm uninstall nbs-gateway 

helm list
echo "removing nifi"
echo "hit return to continue"
read junk
helm uninstall nifi 

helm list
echo "removing modernization-api"
echo "hit return to continue"
read junk
helm uninstall modernization-api 

helm list
echo "removing page-builder-api"
echo "hit return to continue"
read junk
helm uninstall page-builder-api 
 
helm list
echo "removing elasticsearch"
echo "hit return to continue"
read junk
helm uninstall elasticsearch 

helm list
echo "removing keycloak"
echo "hit return to continue"
read junk
helm uninstall keycloak

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

