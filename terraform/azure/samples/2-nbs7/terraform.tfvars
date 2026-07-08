# Please refer to the commentary in ./variables.tf for more info about the variables below.

# The README.md at the top level/folder of this repository has info about how you take a copy of this file and revise it. 
# Unless otherwise specified below, replace each of the strings below in angle brackets (i.e. "<some-string>") with info about the NBS 7 environment you are using this Terraform code to provision the infrastructure for.

################################################################################

# The following variables must be set to the same values that you gave these variables in ../0-landing-zone/terraform.tfvars

# The name of the VNet
vnet_name = "<your_environment_name>-nbs7"

# The name of the Resource Group
vnet_resource_group_name = "nbs7-<your_STLT_name>-<your_environment_name>"

################################################################################

environment_name = "<your_environment_name>"

# These existing certificates must already be created in the Key vault that was provisioned by Layer 0:
agw_key_vault_cert_name_public  = "az-<your_STLT_name>nbs-wildcard-cert-secret"
agw_key_vault_cert_name_private = "az-<your_STLT_name>nbs-wildcard-cert-private"

agw_public_hostname  = "app-<your_environment_name>.az.<your_STLT_name>nbs.com"
agw_private_ip       = "00.0.00.00"
agw_private_hostname = "classic-<your_environment_name>.az.<your_STLT_name>nbs.com"

################################################################################

# Uncomment these variables if you wish to use a different version than the default value in ./variables.tf for these variables:

# The control plane version of the Kubernetes cluster in AKS:
#kubernetes_version_control_plane = "<your_desired_Kubernetes_minor_version>"
# The orchestrator_version of the cluster's default_node_pool:
#kubernetes_default_node_pool_orchestrator_version =  = "<your_desired_Kubernetes_minor_version>"

################################################################################

# [NOTE: The rest of the contents of this file needs to be filled in yet.]
