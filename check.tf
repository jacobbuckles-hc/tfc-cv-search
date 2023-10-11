data "aws_instances" "all" {}

data "aws_instance" "all" {
  for_each = toset(data.aws_instances.all.ids)
  instance_id = each.key
}

output "ec2s" {
  value = join(", ", data.aws_instances.all.ids)
}

output "ec2_other" {
  value = join(", ", [for ec2 in data.aws_instance.all: ec2.id])
}

locals {
        unknown_ec2 = [for ec2 in data.aws_instance.all : ec2.id if lookup(ec2.tags, "ManagedBy", "") != "Terraform"]
}

check "ec2_count_check" {

    assert {
      condition = length(local.unknown_ec2) > 0
      error_message = "Unknown Ec2 instance found: ${local.unknown_ec2[0]}"
    }
}