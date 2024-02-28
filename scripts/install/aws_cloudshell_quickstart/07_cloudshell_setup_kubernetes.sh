#!/bin/bash

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
