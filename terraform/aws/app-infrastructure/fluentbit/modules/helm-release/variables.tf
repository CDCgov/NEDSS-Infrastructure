

variable "tags" {
  type = map(string)
}
variable "namespace" {}
variable "FLUENTBIT_ROLE_ARN" {}
variable "bucket" {}
variable "release_name" {} 
variable "repository" {} 
variable "chart" {}    
variable "SERVICE_ACCOUNT_NAME" {}
variable "path_to_fluentbit" {}



