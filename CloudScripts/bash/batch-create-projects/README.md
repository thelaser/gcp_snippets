# Instructions

This is a script to automatize the creation of several projects using different accounts, providing a file with the names to be used for the accounts.

An example of usage would be for example this:

`./script.sh <containing-folder> <user-organization-ID> <projects-organization-ID> <billing-account-number>`

In this case, the script will create as many projects as lines exist in the [name-list] file existing in the same path than the script.  

These projects will be
created inside the `<containing-folder>`, which is a folder that will be created at the root of the organization. The usernames in each line of the [name-list] file will be joined with the name of the
`<user-organization-ID>`, so if a user is called juan12 and the organization beverlyhills.com, the resulting string will be [juan12@beverlyhills.com]. The `<projects-organization-ID>` defines
the organization where the new projects will be created.

Please note the [name-list] file only contains usernames, not the domain part of the mail. The script expects "juan12", not "juan12@beverlyhills.com".

Finally, the billing account number will be the value of the desired billing account to be used.

## Permissions needed for this

In order for this script to work, one must have the Cloud SDK installed with gcloud logged into an account with "Folder Creator", "Project Creator" and "Project Billing Manager"

## Where can I get the info for the parameters?

To get the info for these paremeters you may need some permissions that give organizations visibility such as `roles/resourcemanager.organizationViewer` or even `roles/resourcemanager.organizationAdmin`  

`<containing-folder>` -> simply creates a folder for the projects, no need for extra info  
`<user-organization-ID>` -> `gcloud organizations list` and get the ID for the org where the user belongs to  
`<projects-organization-ID>` -> same as above and pick the org where the projects will be created in  
`<billing-account-number>` -> `gcloud beta billing accounts list` and choose the corresponding account ID  

## Usage example with values

`./script.sh mygroupofprojects 111111111111 222222222222 AAAAAA-BBBBBB-333333`
