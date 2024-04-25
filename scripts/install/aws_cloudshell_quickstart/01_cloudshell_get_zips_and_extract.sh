#!/bin/bash

# get old repo zip
# will be merged into instructure zip
#

# these need to be updated with each release or prompted and saved in an rc
# file

RELEASE_VER=v7.4.0
INFRA_VER=v1.2.4
HELM_VER=v7.4.0

INFRA_FILE_BASE=nbs-infrastructure-${INFRA_VER}
HELM_FILE_BASE=nbs-helm-${HELM_VER}
INSTALL_DIR=nbs_install
TMP_S3=s3://cdc-nbs-terraform-nbs-video-demo

INFRA_URL=https://github.com/CDCgov/NEDSS-Infrastructure/releases/download/${RELEASE_VER}/${INFRA_FILE_BASE}.zip
HELM_URL=https://github.com/CDCgov/NEDSS-Helm/releases/download/${RELEASE_VER}/${HELM_FILE_BASE}.zip

mkdir -p ~/${INSTALL_DIR}
cd ~/${INSTALL_DIR}




if [ -f ${INFRA_FILE_BASE}.zip ]
then
	echo "INFO: ${INFRA_FILE_BASE}.zip exists, not downloading"

else
	# get modules
	#wget https://github.com/CDCgov/NEDSS-Infrastructure/archive/refs/tags/1.0.0-prerelease.zip
	#mv 1.0.0-prerelease.zip NEDSS-Infrastructure-1.0.0-prerelease.zip

	echo "grabbing file from s3 as a placeholder"
	aws s3 cp ${TMP_S3}/${INFRA_FILE_BASE}.zip .
	# extract temp old repo
	#echo "unzipping infra.zip"
	#unzip -q infra.zip

	echo "getting ${INFRA_URL}"
	#aws s3 cp s3://<local-bucket-placeholder-acct-num>/NEDSS-<repo>-<branchname>.zip infra.zip
	# wget -q ${INFRA_URL}
	# wget ${INFRA_URL}
	#
fi 

if [ -d ${INFRA_FILE_BASE} ]
then
	echo "INFO: ${INFRA_FILE_BASE} exists, not unzipping"
else
	
	#echo "unzipping ${INFRA_FILE_BASE}.zip into ${INFRA_FILE_BASE}"
	echo "unzipping ${INFRA_FILE_BASE}.zip"
	#mkdir -p ${INSTALL_DIR}/${INFRA_FILE_BASE}
	#unzip -q ${INFRA_FILE_BASE}.zip -d ${INFRA_FILE_BASE}
	unzip -q ${INFRA_FILE_BASE}.zip -d ${INFRA_FILE_BASE}
fi

echo "INFO: make the scripts executable"
chmod 755 ${INFRA_FILE_BASE}/scripts/*/*/*.sh

#exit 1
# get helm
#wget  https://github.com/CDCgov/NEDSS-Helm/archive/refs/tags/1.0.0-prerelease.zip
echo 
echo "getting ${HELM_URL}"
aws s3 cp ${TMP_S3}/${HELM_FILE_BASE}.zip .
wget -q ${HELM_URL}
#mv 1.0.0-prerelease.zip NEDSS-Helm-1.0.0-prerelease.zip
#unzip  NEDSS-Helm-1.0.0-prerelease.zip
echo "unzipping ${HELM_FILE_BASE}.zip into ${HELM_FILE_BASE}"
#mkdir -p ${INSTALL_DIR}/${HELM_FILE_BASE}
unzip -q  ${HELM_FILE_BASE}.zip  -d ${HELM_FILE_BASE}


# make scripts executable
#chmod 755 NEDSS-DevOpsTools-*/terraform/aws/account-template/scripts/1_cloudshell_check_install_prereq.sh
#echo "TODO: need to make the scripts executable once they are included in git zip file"
#echo chmod 755 <dirname>/scripts/*.sh
#echo chmod 755 <dirname>/scripts/*.sh

# install pre-reqs in bash/cloudshell/aws linux/RHEL?
#
cd ~/${INSTALL_DIR}
echo "then run ${INSTALL_DIR}/${INFRA_FILE_BASE}/scripts/install/aws_cloudshell_quickstart/02_cloudshell_check_install_prereq.sh and all the other numbered install scripts in order"
#NEDSS-DevOpsTools-*/terraform/aws/account-template/scripts/01_cloudshell_check_install_prereq.sh
# ~/scripts/01_cloudshell_check_install_prereq.sh

exit 0 

#rm *.zip
#cd NEDSS-<repo>-*/terraform/aws/ats-modern*/


#get/create local copy of secrets (can be scripted later) 

# inputs.tfvars template modification documented elsewhere
#aws s3 cp s3://<bucketname>/terraform.tfvars .


#exit 0 

#modify bucket and key in terraform.tf (   bucket  = "state-bucketname"
#    key     = "cdc-nbs-ats-modern/infrastructure-artifacts" ) for s3 backend, choose a local bucket (precreated) 
