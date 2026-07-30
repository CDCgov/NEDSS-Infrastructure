# Please refer to the commentary in ./variables.tf for more info about the variables below.

# The README.md at the top level/folder of this repository has info about how you take a copy of this file and revise it. 
# Unless otherwise specified below, replace each of the strings below in angle brackets (i.e. "<some-string>") with info about the NBS 7 environment you are using this Terraform code to provision the infrastructure for.

################################################################################

environment_name = "<your_environment_name>"

vnet_resource_group_name = "nbs7-<your_STLT_name>-<your_environment_name>"

linkerd_aks_cluster_name = "<your_aks_cluster>"

# Repository to use when installing linkerd
# linkerd_repository = 

# Name of linkerd chart
# linkerd_chart = 

# Name of linkerd namespace
# linkerd_namespace_name = 

# Name of linkerd control plane chart
# linkerd_controlplane_chart = 

# Name of linkerd viz chart
# linkerd_viz_chart = 

# Name of linkerd viz namespace
# linkerd_viz_namespace_name = 

# Whether to install linkerd viz
# linkerd_create_linkerd_viz = 

