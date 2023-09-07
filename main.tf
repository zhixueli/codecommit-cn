
provider "aws" {
  region    = "cn-north-1"
  profile   = "aws_credential_profile_name"          # the aws credentials profile to use
}

# create iam users listed in var.user_names
resource "aws_iam_user" "user" {

  for_each = "${var.user_names}"
  name = each.key
  tags = {
    EmailAddress = each.value[var.email_tag]
  }

}

# add users to iam groups
resource "aws_iam_user_group_membership" "group_membership" {

  for_each = "${var.group_memberships}"
  user   = each.key
  groups = each.value

  depends_on = [ aws_iam_user.user ]

}

# generate iam user HTTPS Git credentials for CodeCommit 
resource "aws_iam_service_specific_credential" "dev_credential" {

  for_each = "${var.user_names}"
  user_name    = each.key

  service_name = "codecommit.amazonaws.com"
  depends_on = [ aws_iam_user.user ]

}

# save the HTTPS Git credentials into local file for each user
resource "local_sensitive_file" "git_users" {

    for_each = "${aws_iam_service_specific_credential.dev_credential}"

    content  = jsonencode(merge({email=var.user_names[each.key][var.email_tag]} ,tomap(each.value)))
    filename = format("%s.%s", each.key, "json")

    depends_on = [ aws_iam_user.user ]
}

# upload credential files to given s3 bucket
# which will trigger lambda to send email to each user
resource "aws_s3_object" "file_uploads" {

    for_each = "${local_sensitive_file.git_users}"

    bucket = var.bucket_name
    key    = format("%s.%s", each.key, "json")
    source = "${path.module}/${each.key}.json"

    depends_on = [ aws_iam_user.user, local_sensitive_file.git_users ]

}