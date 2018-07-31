terraform {
  backend "s3" {
    key    = "${var.infra_state}"
    region = "${var.aws_region}"
  }
}
