
variable "bucket_name" {
    description = "the s3 bucket to upload the git user files"
    default     = "bucket_name"
    type        = string
}

variable "email_tag" {
    default   = "tag_email"
    type      = string
}

variable "user_names" {}

variable "group_memberships" {}