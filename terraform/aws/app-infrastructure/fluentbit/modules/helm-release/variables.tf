

variable "tags" {
  type = map(string)
}
variable "namespace" {}
variable "fluentbit_role_arn" {}
variable "bucket" {}
variable "release_name" {} 
variable "repository" {} 
variable "chart" {}    
variable "service_account_name" {}
variable "path_to_fluentbit" {}



