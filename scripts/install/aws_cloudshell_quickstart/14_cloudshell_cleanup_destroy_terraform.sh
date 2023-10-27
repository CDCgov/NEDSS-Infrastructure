#!/bin/bash
#

#change with each release or prompt and save
INFRA_VER=v1.0.3
echo "change line 5"
exit 1

INSTALL_DIR=nbs_install
cd ~/${INSTALL_DIR}

echo "here are the subdirectories in the terraform/aws directory"
ls -1 NEDSS-Infrastructure-${INFRA_VER}/terraform/aws | grep -v app-infrastructure | grep -v samples


echo "what is the site name"
read TMP_SITE_NAME

#cd NEDSS-DevOpsTools-*/terraform/aws/ats-modern*/

cd NEDSS-Infrastructure-${INFRA_VER}/terraform/aws

#cp samples/NBS6_standard ${TMP_SITE_NAME}

cd ${TMP_SITE_NAME}


echo "initialize terraform modules: "
echo hit return to continue
read junk

terraform init


echo "run  terraform plan"
echo hit return to continue
read junk
terraform plan -var-file=inputs.tfvars


echo "run  terraform destroy"
echo hit return to continue
read junk
terraform destroy -var-file=inputs.tfvars


echo "empty fluentbit s3 bucket manually and rerun terraform destroy"
echo hit return to continue
read junk

echo "run  terraform destroy"
echo hit return to continue
read junk
terraform destroy -var-file=inputs.tfvars
