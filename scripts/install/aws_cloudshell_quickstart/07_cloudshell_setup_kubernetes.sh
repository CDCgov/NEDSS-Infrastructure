#!/bin/bash

# maybe read from inputs.tfvars?
CLUSTER_NAME=cdc-nbs-sandbox

# configure kubectl to point to correct cluster
aws eks --region us-east-1 update-kubeconfig --name ${CLUSTER_NAME}

# check pods, nothing in default until helm charts deployed
echo "listing pods in cert-manager namespace should return 3 pods"
kubectl get pods --namespace=cert-manager

# check nodes, nothing in default until helm charts deployed
echo "listing nodes in eks cluster should return 3 nodes"
kubectl get nodes
