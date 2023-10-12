data "aws_instances" "all" {}

data "aws_instance" "all" {
  for_each = toset(data.aws_instances.all.ids)
  instance_id = each.key
}

locals {
        unknown_ec2 = [for ec2 in data.aws_instance.all : ec2.id if lookup(ec2.tags, "ManagedBy", "") != "Terraform"]
}

check "unknown_ec2" {

    assert {
      condition = length(local.unknown_ec2) == 0
      error_message = "Unknown Ec2 instance(s) found, id(s):  ${join(", ", local.unknown_ec2)}"
    }
}