#!/bin/bash

# this needs to be changed with each release or prompted and saved
INFRA_VER=v1.2.22
#echo "change line 4 and run again"
#exit 1

#INSTALL_DIR=~/nbs_install
INSTALL_DIR=.
DEFAULTS_FILE="./nbs_defaults.sh"
DEBUG=1

# Function to load saved defaults
load_defaults() {
    echo "NOTICE: reading previous values from $DEFAULTS_FILE"
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
    else
        echo "NOTICE: $DEFAULTS_FILE does not exist"
    fi
}
update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "${DEFAULTS_FILE}"; then
        #sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}


load_defaults; 

#cd ~/${INSTALL_DIR}
#cd ${INSTALL_DIR}

rm *.zip
#echo "what is the site name"
#read TMP_SITE_NAME
read -p "Please enter the site name e.g. fts3 [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
update_defaults "SITE_NAME" "$SITE_NAME"

cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/

#echo "not running cp samples/NBS6_standard ${TMP_SITE_NAME}"

#cd ${TMP_SITE_NAME}
if [ $DEBUG -eq 1 ] ; then
        echo "running cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${SITE_NAME}"
        echo "or running cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${TMP_SITE_NAME}"
fi

cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${SITE_NAME}
#cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${TMP_SITE_NAME}

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
