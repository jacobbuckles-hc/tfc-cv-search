# TFC Continuous Validation Search

Demo of using TFC Continuous Validation feature to find EC2 instances that were created outside of Terraform, and using the import feature to generate TF config for the unknown resource to bring it under Terraform management.

Relies on Tags to determine if a EC2 is TF managed or not.

## Prerequisites

- Terraform v1.5+ installed locally 
- AWS account, ideally with no EC2 instances running 

## Steps to Demo

1. Create a workspace in your TFC organization. Opt to use the **CLI workflow**. Go into the workspace settings and **enable Health Assessments** .

2. Clone this repository. Go into [terraform.tf](terraform.tf) and update the cloud block with your organization and workspace that you just created.

3. Run `terraform apply`. This will create an EC2 instance, as well as some networking resources.

4. After the apply has finished, go to the Continuous Validation page in TFC. There will be a assertion called `check.unknown_ec2`. If there are no other EC2 instances in your AWS account in `us-west-2`, this check will be passing. 

5. To get the check to fail, log into your AWS account in the `us-west-2` region and create a new EC2 instance. Once the instance is up and running, go back to TFC and manually start a health assessment. The check should now fail notifying you that an unknown EC2 instance was found, the warning will also display the `id` of the unknown instance.

6. To demonstrate the import functionality, copy the `id` from the warning message. Go to [import.tf](import.tf), uncomment the import block and paste in the `id` value. 

7. Run the command:
```
terraform plan -generate-config-out=generated.tf
```
This will create a file called `generated.tf`, with a resource block describing the imported resource. There is currently an error where Terraform will say: `"ipv6_address_count": conflicts with ipv6_addresses`. This issue is documented [here](https://developer.hashicorp.com/terraform/language/import/generating-configuration#conflicting-resource-arguments). To fix, go into `generated.tf`, and delete one of the two arguments. 

8. You can now run `terraform plan` and `terraform apply` to import the resource. **Note:** since the Continuous Validation is relying on tagging to find unknown resources, the check will still fail. This can be resolved by adding `ManagedBy = "Terraform"` to the tags argument in the generated resource.