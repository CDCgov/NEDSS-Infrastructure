#!/bin/bash

# Description:
# This script automates the installation or upgrade of an NGINX Ingress controller
# in a Kubernetes cluster using Helm. It supports specifying Helm version and
# installation directory through flags or prompts. Features include saving defaults,
# debug logging, step-by-step execution, a test mode, and preliminary access checks
# for AWS account and Kubernetes cluster connectivity.

# Default values
HELM_VER_DEFAULT=v7.8.1
INGRESS_VER=4.7.2
INSTALL_DIR_DEFAULT=~/nbs_install
DEFAULTS_FILE="nbs_defaults.sh"
DEBUG=1
STEP=0
NOOP=0

# Load defaults if available
if [ -f "$DEFAULTS_FILE" ]; then
    source "$DEFAULTS_FILE"
else
    echo "${DEFAULTS_FILE} not found. Using script defaults."
fi

# Update defaults file function
#update_defaults() {
#    [ $NOOP -eq 1 ] && return
#    local var_name=$1
#    local var_value=$2
#    if grep -q "^${var_name}=" "$DEFAULTS_FILE"; then
#        sed -i "s/^${var_name}=.*/${var_name}=${var_value}/" "$DEFAULTS_FILE"
#    else
#        echo "${var_name}=${var_value}" >> "$DEFAULTS_FILE"
#    fi
#}

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


# Function to show usage
usage() {
    echo "Usage: $0 [-h] [-v HELM_VER] [-d INSTALL_DIR] [-g] [-s] [-t]"
    echo "  -h  Show this help message."
    echo "  -v  Specify Helm version (default: ${HELM_VER_DEFAULT})."
    echo "  -d  Specify installation directory (default: ${INSTALL_DIR_DEFAULT})."
    echo "  -g  Enable debug mode."
    echo "  -s  Enable step-by-step execution."
    echo "  -t  Test mode (no operations performed)."
    exit 1
}

execute_command() {
    local cmd=$1
    if [ $DEBUG -eq 1 ] || [ $NOOP -eq 1 ]; then
        echo "Command: $cmd"
    fi
    if [ $STEP -eq 1 ]; then
        read -p "Press enter to continue..."
    fi
    if [ $NOOP -eq 0 ]; then
        eval $cmd
    else
        echo "No-Op: Command not executed."
    fi
}


# Parse options
while getopts "hv:d:gst" opt; do
    case ${opt} in
        h)
            usage
            ;;
        v)
            HELM_VER="$OPTARG"
            ;;
        d)
            INSTALL_DIR="$OPTARG"
            ;;
        g)
            DEBUG=1
            ;;
        s)
            STEP=1
            ;;
        t)
            NOOP=1
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            usage
            ;;
        :)
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Preliminary Access Checks
#if [ $NOOP -eq 0 ]; then
    if ! execute_command "aws sts get-caller-identity > /dev/null"; then
        echo "Error verifying AWS access."
        exit 1
    fi

    if ! execute_command "kubectl cluster-info > /dev/null"; then
        echo "Error verifying Kubernetes cluster access."
        exit 1
    fi
#fi

# Prompt for missing values with defaults
read -p "Please enter Helm version [${HELM_VER_DEFAULT}]: " input_helm_ver
HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
update_defaults HELM_VER $HELM_VER

read -p "Please enter installation directory [${INSTALL_DIR_DEFAULT}]: " input_install_dir
INSTALL_DIR=${input_install_dir:-$INSTALL_DIR_DEFAULT}
update_defaults INSTALL_DIR $INSTALL_DIR

read -p "Please enter SITE NAME[${SITE_NAME_DEFAULT}]: " input_site_name
SITE_NAME=${input_site_name:-$SITE_NAME_DEFAULT}
update_defaults SITE_NAME $SITE_NAME

# Proceed with the rest of the script
HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}
[ $NOOP -eq 0 ] && execute_command "cd ${HELM_DIR}/charts"

# nginx ingress installation
#execute_command "helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx -f nginx-ingress/values.yaml --namespace ingress-nginx --create-namespace --version ${INGRESS_VER}"
execute_command "helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx -f nginx-ingress/values-${SITE_NAME}.yaml --namespace ingress-nginx --create-namespace --version ${INGRESS_VER}"

echo "sleeping for 30 seconds to allow provisioning to complete"
sleep 30
# Check for running pods in ingress-nginx namespace
execute_command "kubectl get po -n ingress-nginx"
execute_command "kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller"

echo " now make sure efs volume ID is correct in elasticsearch-efs"
echo " make sure private route 53 zone is bound to modern vpc"
echo " make sure private dns record for jdbc host is in private domain"
echo " make sure you can connect from modern-private-subnets (EKS) to dns"
echo " verify NLB is now created and map dns names for app, nifi,"
echo " data pointing to NLB and app-classic to alb"
