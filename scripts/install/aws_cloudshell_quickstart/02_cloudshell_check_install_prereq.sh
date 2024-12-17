#!/bin/bash

# bash script to check for specific versions and install if missing aws cli, terraform, eksutil  and helm in an aws cloudshell system
# include prompt before each install, include variables for minimum version number of each tool

cd ~

# Set minimum versions for each tool
MIN_AWSCLI_VERSION="2.13.14"
MIN_TERRAFORM_VERSION="1.5.6"
MIN_EKSCTL_VERSION="0.141.0"
MIN_HELM_VERSION="3.11.0"
MIN_JQ_VERSION="1.4"
MIN_KUBECTL_VERSION="1.26"

# this needs to be in your path
INSTALL_DIR=/usr/local
#INSTALL_DIR=/opt/local
# discouraged
#INSTALL_DIR=/


# Default flags
auto_yes=false
quiet_mode=false
PROMPT="y" # Change to "n" to disable prompt

# Usage information
usage() {
    echo "Usage: $0 [-y] [-q] [-?]"
    echo "  -y    Automatic yes to prompts; assume 'yes' as answer to all prompts and run non-interactively."
    echo "  -q    Quiet mode; minimize output."
    echo "  -?    Display this help and exit."
}

# Parse command-line options
while getopts "yq?" opt; do
    case $opt in
        y) auto_yes=true ;;
        q) quiet_mode=true ;;
        ?) usage
           exit ;;
        *) usage
           exit 1 ;;
    esac
done



# Function to compare version numbers
version_compare() {
    # Using 'sort -V' for version comparison and picking the first line
    local result=$(echo -e "$1\n$2" | sort -V | head -n 1)
    [[ $1 == $result ]]
}

check_install_dir() {
	if [ -d ${INSTALL_DIR} ]
	then
		echo "${INSTALL_DIR} exists, good"
	else
		echo "${INSTALL_DIR} does not exist, creating"
		mkdir -p ${INSTALL_DIR}
		echo "WARNING: makes sure ${INSTALL_DIR} is in your path"
	fi
}



# Check and install AWS CLI
current_awscli_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
#echo "$current_awscli_version  version_compare $current_awscli_version $MIN_AWSCLI_VERSION"
if [[ -z "$current_awscli_version" ]] || version_compare "$current_awscli_version" "$MIN_AWSCLI_VERSION"; then
    if [ "$auto_yes" = true ]; then
        [ "$quiet_mode" = false ] && echo "Auto-installing aws cli as '-y' flag is set"
        	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        	unzip awscliv2.zip
            if `aws --version  2>&1 > /dev/null`
            then
                echo "pre-existing aws, updating"
        	    sudo ./aws/install --update
            else
        	    sudo ./aws/install
            fi
        	rm -rf awscliv2.zip
    else
    	read -p "AWS CLI is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    	if [[ $choice == "y" ]]; then
        	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        	unzip awscliv2.zip
            if `aws --version  2>&1 > /dev/null`
            then
                echo "pre-existing aws, updating"
        	    sudo ./aws/install --update
            else
        	    sudo ./aws/install
            fi
        	rm -rf awscliv2.zip
    	fi
    fi
fi
#exit 1


# Check and install jq
if ! jq --version > /dev/null 2>&1 || version_compare "$(jq --version | cut -d- -f2)" "$MIN_JQ_VERSION"; then
    if [ "$auto_yes" = true ]; then
        [ "$quiet_mode" = false ] && echo "Auto-installing jq as '-y' flag is set"
    	if [[ $choice == "y" ]]; then
		echo "installing jq"
        	sudo yum install -y jq -q
    	fi
    else
    	read -p "jq is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    	if [[ $choice == "y" ]]; then
		echo "installing jq"
        	sudo yum install -y jq -q
    	fi
    fi
fi

# Check and install Terraform
if ! terraform version > /dev/null 2>&1 || version_compare "$(terraform version | head -n 1 | cut -d'v' -f2)" "$MIN_TERRAFORM_VERSION"; then
    if [ "$auto_yes" = true ]; then
        [ "$quiet_mode" = false ] && echo "Auto-installing Terraform as '-y' flag is set"
	echo "installing terraform"
        sudo yum install -y yum-utils -q 
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo > /dev/null 2>&1
        sudo yum install terraform-1.5.5-1 -y -q
    else
    	read -p "Terraform is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    	if [[ $choice == "y" ]]; then
		echo "installing terraform"
        	sudo yum install -y yum-utils -q 
        	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo > /dev/null 2>&1
        	sudo yum install terraform-1.5.5-1 -y -q
    	fi
    fi
fi

# Check and install kubectl
if ! kubectl version > /dev/null 2>&1 || version_compare "$(kubectl version --client | grep "Client Version" | awk -F':' '{print $2}'| cut -d'v' -f2)" "$MIN_KUBECTL_VERSION"; then
    if [ "$auto_yes" = true ]; then
        [ "$quiet_mode" = false ] && echo "Auto-installing kubectl as '-y' flag is set"
	echo "installing kubectl"
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	check_install_dir;
	sudo install -o root -g root -m 0755 kubectl ${INSTALL_DIR}/bin/kubectl
    else
    	read -p "kubectl is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    	if [[ $choice == "y" ]]; then
		echo "installing kubectl"
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		check_install_dir;
		sudo install -o root -g root -m 0755 kubectl ${INSTALL_DIR}/bin/kubectl
    	fi
    fi
fi


# Check and install eksctl
if ! eksctl version > /dev/null 2>&1 || version_compare "$(eksctl version)" "$MIN_EKSCTL_VERSION"; then
    if [ "$auto_yes" = true ]; then
        [ "$quiet_mode" = false ] && echo "Auto-installing eksutil as '-y' flag is set"
        sudo yum install -y openssl -q
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	check_install_dir;
        sudo mv /tmp/eksctl ${INSTALL_DIR}/bin
    else
    	read -p "eksctl is missing or its version is less than the minimum. Install/Update? (y/n) " choice
    	if [[ $choice == "y" ]]; then
        	sudo yum install -y openssl -q
        	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
		check_install_dir;
        	sudo mv /tmp/eksctl  ${INSTALL_DIR}/bin
    	fi
    fi
fi

if ! helm version --short > /dev/null 2>&1 || version_compare "$(helm version --short | cut -d'v' -f2)" "$MIN_HELM_VERSION"; then
    if [ "$auto_yes" = true ]; then
        [ "$quiet_mode" = false ] && echo "Auto-installing Helm as '-y' flag is set"
        sudo yum install -y openssl -q
        curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    else
        read -p "Helm is missing or its version is less than the minimum. Install/Update? (y/n) " choice
        if [[ $choice == "y" ]]; then
            sudo yum install -y openssl -q
            curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
        fi
    fi
fi


if `which yum > /dev/null`  
then
    echo "installing telnet and bind for testing"
    sudo yum install -y telnet bind-utils -q
fi

echo "All tools checked and installed/updated as necessary."


# Check the versions of the installed tools
echo "AWS CLI version: $(aws --version)"
echo "jq version: $(jq --version)"
echo "Terraform version: $(terraform --version | head -1 )"
echo "eksctl version: $(eksctl version)"
echo "Helm version: $(helm version)"
echo "kubectl version: $(kubectl version --client | grep "Client Version" | awk -F':' '{print $2}')"

