variable "project" {
  description = "Project name."
  type        = string
  default     = "mattermost"
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "tom"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use locally."
  type        = string
  default     = "Tom"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}