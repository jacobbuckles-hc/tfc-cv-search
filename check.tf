data "aws_instances" "all" {}

data "aws_instance" "all" {
  for_each = data.aws_instances.all
  instance_id = each.value.id
}

locals {
        unknown_ec2 = [for ec2 in data.aws_instance.all : ec2 if lookup(ec2.tags, "ManagedBy", "") != "Terraform"]
    }

check "ec2_count_check" {

    assert {
      condition = length(local.unknown_ec2) > 0
      error_message = "Unknown Ec2 instance found: ${local.unknown_ec2[0].id}"
    }
}