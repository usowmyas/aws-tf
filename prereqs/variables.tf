variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {}

variable "aws_key_name" {}

variable "aws_infra_bucket" {
  default = "mt-infra"
}

variable "aws_apps_bucket" {
  default = "mt-apps"
}

variable "aws_dynamodb_table" {
  default = "mt-tfstatelock"
}

variable "user_home_path" {
  default = "D:\\Accelerators\\aws-tf\\prereqs"
}
