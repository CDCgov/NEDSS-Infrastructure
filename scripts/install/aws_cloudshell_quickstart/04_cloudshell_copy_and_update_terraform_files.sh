#!/bin/bash

# can get this with cli
ACCT_NUM=0000000

# modify this for each release or prompt and save to rc file
INFRA_VER=v1.2.17

#INSTALL_DIR=nbs_install
INSTALL_DIR=./nbs_install

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

#cd ~/${INSTALL_DIR}
cd ${INSTALL_DIR}
rm *.zip

echo "what is the site name"
read TMP_SITE_NAME

#cd NEDSS-DevOpsTools-*/terraform/aws/ats-modern*/

#cd NEDSS-Infrastructure-1.0.0-prerelease/terraform/aws
cd nbs-infrastructure-${INFRA_VER}/

if [ -d  ${TMP_SITE_NAME} ]
then
	echo "INFO:  ${TMP_SITE_NAME} already exists"
	#echo "INFO:  ${TMP_SITE_NAME} already exists, exiting"
	#exit 1
else
	#cp -pr samples/NBS7_standard ${TMP_SITE_NAME}
	#cp -pr terraform/aws/samples/NBS7_standard ${TMP_SITE_NAME}
	cp -pr terraform/aws/samples/NBS7_standard terraform/aws/${TMP_SITE_NAME}
fi

cd terraform/aws/${TMP_SITE_NAME}

# 
# cd NEDSS-DevOpsTools-*/terraform/aws/ats-modern*/


#get/create local copy of secrets (can be scripted later) 

# inputs.tfvars template modification documented elsewhere

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

vi terraform.tf

# echo "now need to hand edit terraform.tfvars before running next script"
echo "now need to hand edit inputs.tfvars before running next script"
echo "cd `pwd`"

