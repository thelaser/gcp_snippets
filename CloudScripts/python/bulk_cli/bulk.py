import argparse

parser = argparse.ArgumentParser()

subparsers = parser.add_subparsers(help='sub-command help')

checkperms = subparsers.add_parser('chkperm', help='Batch check permissions help')

permissions = subparsers.add_parser('addperm', help='Batch add permissions for several users')
permissions.add_argument('-r','--role', type=str, help='Role to add')
permissions.add_argument('-b','--billing_project', type=str, help='Billing account to be attached the new projects')

project = subparsers.add_parser('project', help='Batch project creation help')
project.add_argument('-r','--role', type=str, help='User account')

#main_options = parser.add_mutually_exclusive_group(required=True)
#main_options.add_argument("perm", "permissions")
#main_options.add_argument("prj", "project")

parser.add_argument("-org","--organization_id", help="The organization ID of the aimed org")
args = parser.parse_args()


print(args.organization_id)
print(args.role)
print(args.billing_project)
