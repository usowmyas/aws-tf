resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "mtinfra" {
  bucket        = "${var.aws_infra_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforAppTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.devuser.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_infra_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.testuser.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_infra_bucket}",
                "arn:aws:s3:::${var.aws_infra_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "mtapps" {
  bucket        = "${var.aws_apps_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforInfraTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.testuser.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_apps_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.devuser.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_apps_bucket}",
                "arn:aws:s3:::${var.aws_apps_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user" "devuser" {
  name = "devuser"
}

resource "aws_iam_user_policy" "devuser_rw" {
  name = "devuser"
  user = "${aws_iam_user.devuser.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_apps_bucket}",
                "arn:aws:s3:::${var.aws_apps_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_user" "produser" {
  name = "produser"
}

resource "aws_iam_access_key" "produser" {
  user = "${aws_iam_user.produser.name}"
}

resource "aws_iam_user_policy" "produser_rw" {
  name = "produser"
  user = "${aws_iam_user.produser.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_apps_bucket}",
                "arn:aws:s3:::${var.aws_apps_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_user" "testuser" {
  name = "testuser"
}

resource "aws_iam_access_key" "testuser" {
  user = "${aws_iam_user.testuser.name}"
}

resource "aws_iam_user_policy" "testuser_rw" {
  name = "testuser"
  user = "${aws_iam_user.testuser.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_infra_bucket}",
                "arn:aws:s3:::${var.aws_infra_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_access_key" "devuser" {
  user = "${aws_iam_user.devuser.name}"
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    "${aws_iam_user.devuser.name}",
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

resource "local_file" "aws_keys" {
  content = <<EOF
[default]
aws_access_key_id = ${var.aws_access_key}
aws_secret_access_key = ${var.aws_secret_key}

[devuser]
aws_access_key_id = ${aws_iam_access_key.devuser.id}
aws_secret_access_key = ${aws_iam_access_key.devuser.secret}

[testuser]
aws_access_key_id = ${aws_iam_access_key.testuser.id}
aws_secret_access_key = ${aws_iam_access_key.testuser.secret}

[produser]
aws_access_key_id = ${aws_iam_access_key.produser.id}
aws_secret_access_key = ${aws_iam_access_key.produser.secret}

EOF

  filename = "${var.user_home_path}/.aws/credentials"
}
