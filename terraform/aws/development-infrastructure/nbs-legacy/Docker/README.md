# Creating NB6 Docker Image

## Description

The creation of NB6 Docker version is currently a manual process. Foundation image used is Microsoft Server Core ltsc2019. Additional details, inclusive of licensing information, are available at https://hub.docker.com/_/microsoft-windows-servercore/. 

## Files
Dockerfile - Configuration file to build docker image
entrypoint.ps1 - Docker entrypoint script to run each time a container runs

## Steps

- Build Docker Container. This should built locally or on an instance with docker installed and access to ECR Repository
-- Verify you're in nbs-legacy -> Docker directory
-- Run: docker build . -t nbs6
-- Verify container was build successfully
- Push Image to Private ECR Repository
-- Run: docker tag nbs6:latest <shared-account-id>.dkr.ecr.us-east-1.amazonaws.com/cdc-nbs-legacy/nbs6:latest
-- Login ECR: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <shared-account-id>.dkr.ecr.us-east-1.amazonaws.com
-- Push to ECR latest: docker push <shared-account-id>.dkr.ecr.us-east-1.amazonaws.com/cdc-nbs-legacy/nbs6:6.0.15.1
-- Push to ECR NBS Version Tag: docker push <shared-account-id>.dkr.ecr.us-east-1.amazonaws.com/cdc-nbs-legacy/nbs6:6.0.15.1
- Deploy NB6 Container
-- When deploying, DATABASE_ENDPOINT variable key and value is required.