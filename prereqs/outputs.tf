output "devuser-access-key" {
  value = "${aws_iam_access_key.devuser.id}"
}

output "devuser-secret-key" {
  value = "${aws_iam_access_key.devuser.secret}"
}

output "testuser-access-key" {
  value = "${aws_iam_access_key.testuser.id}"
}

output "testuser-secret-key" {
  value = "${aws_iam_access_key.testuser.secret}"
}

output "produser-access-key" {
  value = "${aws_iam_access_key.testuser.id}"
}

output "produser-secret-key" {
  value = "${aws_iam_access_key.testuser.secret}"
}
