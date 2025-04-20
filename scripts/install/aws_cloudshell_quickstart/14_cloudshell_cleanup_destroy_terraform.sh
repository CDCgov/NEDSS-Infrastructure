#!/bin/bash
HELM_VER=v7.9.1.1
#exit 1
INSTALL_DIR=~/nbs_install
INFRA_VER=v1.2.33
DEBUG=1
STEP=1
NOOP=0
SLEEP_TIME=60
# must edit with each release or prompt and save
# Default file for storing selected values and entered credentials
DEFAULTS_FILE="`pwd`/nbs_defaults.sh"

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


load_defaults;


# Prompt for missing values with defaults
read -p "Please enter Helm version [${HELM_VER_DEFAULT}]: " input_helm_ver
HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
update_defaults HELM_VER $HELM_VER
read -p "Please enter Infrastructure version [${INFRA_VER_DEFAULT}]: " input_infra_ver
INFRA_VER=${input_infra_ver:-$INFRA_VER_DEFAULT}
update_defaults INFRA_VER $INFRA_VER
# INFRA_VER=v1.2.4

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


#cd ~/${INSTALL_DIR}
cd ${INSTALL_DIR}
echo PWD=`pwd`

echo "here are the subdirectories in the terraform/aws directory"
#ls -1 NEDSS-Infrastructure-${INFRA_VER}/terraform/aws | grep -v app-infrastructure | grep -v samples
ls -1 nbs-infrastructure-${INFRA_VER}/terraform/aws | grep -v app-infrastructure | grep -v samples


#echo "what is the site name"
#read TMP_SITE_NAME

#cd NEDSS-DevOpsTools-*/terraform/aws/ats-modern*/

#cd NEDSS-Infrastructure-${INFRA_VER}/terraform/aws
cd nbs-infrastructure-${INFRA_VER}/terraform/aws
echo PWD=`pwd`

#cp samples/NBS6_standard ${TMP_SITE_NAME}

cd ${SITE_NAME}
echo PWD=`pwd`


echo "initialize terraform modules: "
echo hit return to continue
read junk

terraform init


echo "run  terraform plan"
echo hit return to continue
read junk
#terraform plan -var-file=inputs.tfvars
terraform plan


echo "run  terraform destroy"
echo hit return to continue
read junk
#terraform destroy -var-file=inputs.tfvars
terraform destroy

remove_dns app-classic.${SITE_NAME}.${EXAMPLE_DOMAIN};

echo "empty fluentbit s3 bucket manually and rerun terraform destroy"
echo hit return to continue
read junk

echo "run  terraform destroy"
echo hit return to continue
read junk
#terraform destroy -var-file=inputs.tfvars
terraform destroy
