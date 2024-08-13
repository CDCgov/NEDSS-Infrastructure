#!/bin/bash

# this needs to be changed with each release or prompted and saved
INFRA_VER=v1.2.14
echo "change line 4 and run again"
exit 1

INSTALL_DIR=nbs_install
DEFAULTS_FILE="./nbs_defaults.sh"

# Function to load saved defaults
load_defaults() {
    echo "NOTICE: reading previous values from $DEFAULTS_FILE"
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
    else
        echo "NOTICE: $DEFAULTS_FILE does not exist"
    fi
}
load_defaults; 

cd ~/${INSTALL_DIR}

rm *.zip
echo "what is the site name"
read TMP_SITE_NAME

cd nbs-infrastructure-${INFRA_VER}/

echo " not running cp samples/NBS6_standard ${TMP_SITE_NAME}"

cd ${TMP_SITE_NAME}

echo " this is where we need to add another script to fill out inputs.tfvars"
echo " we should also check that the VPC id for classic is correct as well as the route tables ids"
echo "hit return to continue"
read junk

echo "initialize terraform modules: "
echo hit return to continue
read junk

terraform init

echo "run  terraform plan"
echo hit return to continue
read junk
terraform plan -var-file=inputs.tfvars

echo "run  terraform apply"
echo hit return to continue
read junk
terraform apply -var-file=inputs.tfvars
