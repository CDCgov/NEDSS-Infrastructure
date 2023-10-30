#!/bin/bash
#
# Placeholder, for now copy customized files already created for this specific environment
#

# must edit on each release or prompt and save
HELM_VER=v1.0.0

INSTALL_DIR=nbs_install
cd ~/${INSTALL_DIR}

ZIP_FILE=helm-ats.zip
S3_BUCKET=install-placeholder-${ACCT_NUM}/tmptestzips
echo "edit line 7, 9 and rerun"
exit 1

TMP_COPY_DIR=helm-ats

#CHARTS_DIR=NEDSS-Helm-1.0.0-prerelease/charts
CHARTS_DIR=nbs-helm-${HELM_VER}/charts

aws s3 cp s3://${S3_BUCKET}/${ZIP_FILE} .
unzip ${ZIP_FILE}

update_values_file()
{
	# this should eventually use existing file as a template and do a search and replace
	# prompting if needed for values
	#
	TMP_HELM_CHART=$1

	echo "copying precreated  ${TMP_COPY_DIR}/${TMP_HELM_CHART}/values.yaml $to ${CHARTS_DIR}/${TMP_HELM_CHART}/values.yaml"

	# backup original 
	cp -p ${CHARTS_DIR}/${TMP_HELM_CHART}/values.yaml  ${CHARTS_DIR}/${TMP_HELM_CHART}/values.yaml.orig
	cp -p ${TMP_COPY_DIR}/${TMP_HELM_CHART}/values.yaml ${CHARTS_DIR}/${TMP_HELM_CHART}/values.yaml


}

update_values_file elasticsearch-efs;
update_values_file modernization-api;
update_values_file nbs-gateway;
update_values_file nginx-ingress;
update_values_file nifi;


echo " now make sure efs volume ID is correct in elasticsearch-efs"
echo " make sure private route 53 zone is bound to modern vpc"
echo " make sure private dns record for jdbc host is in private domain"
echo " make sure you can connect from modern-private-subnets (EKS) to dns"
