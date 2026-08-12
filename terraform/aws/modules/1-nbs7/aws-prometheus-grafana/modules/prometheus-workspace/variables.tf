variable "retention_in_days" {
  description = "The number of days to keep the log data"
  type        = number
}

variable "alias" {
  description = "The alias to give the resource"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}

variable "region" {
  description = "The AWS region to use for the resources"
  type        = string
}

variable "resource_prefix" {
  description = "The prefix text to add to the start of each resource name"
  type        = string
}

