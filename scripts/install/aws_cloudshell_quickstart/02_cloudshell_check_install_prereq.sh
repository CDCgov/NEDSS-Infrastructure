#!/bin/bash

# bash script to check for specific versions and install if missing aws cli, terraform, eksutil  and helm in an aws cloudshell system
# include prompt before each install, include variables for minimum version number of each tool

cd ~

# Set minimum versions for each tool
MIN_AWSCLI_VERSION="2.13.14"
MIN_TERRAFORM_VERSION="1.5.4"
MIN_EKSCTL_VERSION="0.141.0"
MIN_HELM_VERSION="3.11.0"
MIN_JQ_VERSION="1.4"

PROMPT="y" # Change to "n" to disable prompt



# Function to compare version numbers
version_compare() {
    # Using 'sort -V' for version comparison and picking the first line
    local result=$(echo -e "$1\n$2" | sort -V | head -n 1)
    [[ $1 == $result ]]
}

# Check and install AWS CLI
current_awscli_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
if [[ -z "$current_awscli_version" ]] || version_compare "$current_awscli_version" "$MIN_AWSCLI_VERSION"; then
    read -p "AWS CLI is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    if [[ $choice == "y" ]]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip
    fi
fi


# Check and install jq
if ! jq --version > /dev/null 2>&1 || version_compare "$(jq --version | cut -d- -f2)" "$MIN_JQ_VERSION"; then
    read -p "jq is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    if [[ $choice == "y" ]]; then
	echo "installing jq"
        sudo yum install -y jq -q
    fi
fi

# Check and install Terraform
if ! terraform version > /dev/null 2>&1 || version_compare "$(terraform version | head -n 1 | cut -d'v' -f2)" "$MIN_TERRAFORM_VERSION"; then
    read -p "Terraform is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    if [[ $choice == "y" ]]; then
	echo "installing terraform"
        sudo yum install -y yum-utils -q 
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo > /dev/null 2>&1
        sudo yum install terraform-1.5.5-1 -y -q
        #wget https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
        #unzip terraform_1.0.8_linux_amd64.zip
        #sudo mv terraform /usr/local/bin/
        #rm terraform_1.0.8_linux_amd64.zip
    fi
fi

# Check and install eksctl
if ! eksctl version > /dev/null 2>&1 || version_compare "$(eksctl version)" "$MIN_EKSCTL_VERSION"; then
    read -p "eksctl is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    if [[ $choice == "y" ]]; then
        sudo yum install -y openssl -q
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
    fi
fi

# Check and install Helm
if ! helm version --short > /dev/null 2>&1 || version_compare "$(helm version --short | cut -d'v' -f2)" "$MIN_HELM_VERSION"; then
    read -p "Helm is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    if [[ $choice == "y" ]]; then
        sudo yum install -y openssl -q
        curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    fi
fi


sudo yum install -y telnet bind-utils -q

echo "All tools checked and installed/updated as necessary."


# Check the versions of the installed tools
echo "AWS CLI version: $(aws --version)"
echo "jq version: $(jq --version)"
echo "Terraform version: $(terraform --version | head -1 )"
echo "eksctl version: $(eksctl version)"
echo "Helm version: $(helm version)"

