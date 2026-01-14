##################################  GENERAL  ###################################

variable "region" {
  description = "The region to operate on"
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix name for each customer"
  type        = string
  default     = "firstinfra"
}

variable "env_name" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
