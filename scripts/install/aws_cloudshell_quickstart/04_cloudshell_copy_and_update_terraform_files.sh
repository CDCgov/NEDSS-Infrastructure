#!/bin/bash

# can get this with cli
ACCT_NUM=0000000

# modify this for each release or prompt and save to rc file
INFRA_VER=v1.2.33
SAMPLE_DIR=NBS7_standard
#SAMPLE_DIR=NBS6_7

#INSTALL_DIR=nbs_install
INSTALL_DIR=./nbs_install

#DEFAULTS_FILE="`pwd`/nbs_defaults.sh"
source "$(dirname "$0")/../../common_functions.sh"

# Function to load saved defaults
#load_defaults() {
#    echo "NOTICE: reading previous values from $DEFAULTS_FILE"
#    if [ -f "$DEFAULTS_FILE" ]; then
#        source "$DEFAULTS_FILE"
#    else
#        echo "NOTICE: $DEFAULTS_FILE does not exist"
#    fi
#}

# Function to update defaults file
#update_defaults() {
#    local var_name=$1
#    local var_value=$2
#    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
#        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
#    else
#        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
#    fi
#}


load_defaults; 

#cd ~/${INSTALL_DIR}
cd ${INSTALL_DIR}
rm *.zip

# Prompts for additional information
read -p "Please enter the site name e.g. fts3 [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
# read -p "Enter Image Name [$IMAGE_NAME_DEFAULT]: " IMAGE_NAME && IMAGE_NAME=${IMAGE_NAME:-$IMAGE_NAME_DEFAULT}
update_defaults "SITE_NAME" "$SITE_NAME"

#echo "what is the site name"
#read TMP_SITE_NAME

#cd NEDSS-DevOpsTools-*/terraform/aws/ats-modern*/

#cd NEDSS-Infrastructure-1.0.0-prerelease/terraform/aws
cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/

if [ -d  ${SITE_NAME} ]
then
	echo "INFO:  ${SITE_NAME} already exists"
	#echo "INFO:  ${SITE_NAME} already exists, exiting"
	#exit 1
else
	#cp -pr samples/NBS7_standard ${SITE_NAME}
	#cp -pr terraform/aws/samples/NBS7_standard ${SITE_NAME}
	cp -pr terraform/aws/samples/${SAMPLE_DIR} terraform/aws/${SITE_NAME}
	#cp -pr terraform/aws/samples/${SAMPLE_DIR} ${INSTALL_DIR}/${SITE_NAME}
fi

cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${SITE_NAME}

# 
# cd NEDSS-DevOpsTools-*/terraform/aws/ats-modern*/


#get/create local copy of secrets (can be scripted later) 

# terraform.tfvars template modification documented elsewhere

# echo aws s3 cp s3://install-placeholder-<account-num>/terraform.tfvars terraform.tfvars.froms3
# edit bucket name and uncomment
#aws s3 cp s3://install-placeholder-${ACCT_NUM}/terraform.tfvars terraform.tfvars.froms3

#exit 1 


echo "modify terraform.tfars and/or inputs.tfvars to reflect appropriate values"
echo "replace any variables with EXAMPLE in the name!"

echo "modify bucket and key in terraform.tf"
echo "e.g. bucket  = "install-placeholder-${ACCT_NUM}"
echo "key     = "cdc-nbs-ats-modern/infrastructure-artifacts" 
echo "for s3 backend, choose a local bucket (precreated) probably with versioning enabled"

echo hit return to continue
read junk


# backup existing terraform.tf file
# should eventually use date instead of "save"
if [ -f terraform.tf ]
then
    cp -p terraform.tf terraform.tf.save
fi

cp -p terraform.tf.tpl terraform.tf
vi terraform.tf

# echo "now need to hand edit terraform.tfvars before running next script"
echo "now need to hand edit inputs.tfvars before running next script"
echo "cd `pwd`"

