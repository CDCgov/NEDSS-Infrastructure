#!/bin/bash

# Function to check AWS access and confirm account
check_aws_access() {
    local account_id=$(aws sts get-caller-identity --query "Account" --output text)
    local account_user=$(aws sts get-caller-identity --query "Arn" --output text | awk -F':' '{print $6}')
    #local account_alias=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)
    if [ -z "$account_id" ]; then
        echo "Error verifying AWS access."
        exit 1
    else
        echo "You are currently accessing AWS Account ID: $account_id as user: ${account_user}"
        # aws  iam list-account-aliases only works from organization owner
        # account
        #echo "Account Alias: $account_alias"
        # echo "Account Alias: not available except from organization owner"
        read -p "Is this the intended AWS account/user? (y/n): " confirmation
        if [[ "$confirmation" != "y" ]]; then
            echo "AWS account verification failed. Exiting."
            exit 1
        fi
    fi
}

check_aws_access; 

# maybe read from inputs.tfvars?
#TMP_CLUSTER=cdc-nbs-sandbox
echo "grabbing cluster name from current environment, THIS ONLY WORKS IF THERE IS ONLY ONE CLUSTER"
TMP_CLUSTER=$(aws eks list-clusters --query 'clusters' --output text)

# configure kubectl to point to correct cluster
aws eks --region us-east-1 update-kubeconfig --name ${TMP_CLUSTER}

# check pods, nothing in default until helm charts deployed
echo "listing pods in cert-manager namespace should return 3 pods"
kubectl get pods --namespace=cert-manager

# check nodes, nothing in default until helm charts deployed
echo "listing nodes in eks cluster should return 3 nodes"
kubectl get nodes
