
user_names = {

    # the users to be created in iam

    "developer1" = {
        tag_email     = "developer1@example.com"
    }

    "developer2" = {
        tag_email     = "developer2@example.com"
    }

    "tester1" = {
        tag_email     = "tester1@example.com"
    }

    "tester2" = {
        tag_email     = "tester2@example.com"
    }

}

group_memberships = {
    # the groups that users will be associated
    # groups need to be created in adavance before users created
    "developer1" = [ "developer", "tester" ]
    "developer2" = [ "developer" ]
    "tester1" = [ "tester" ]
    "tester2" = [ "tester" ]
}