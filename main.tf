locals {
  tag_name = coalesce(var.tag_name, var.hostname)

  volume_mounts = join("\n", [
    for device, volume in var.additional_volumes :
    templatefile(
      "${path.module}/user_data_scripts/mount_volume.sh",
      {
        device      = device
        mount_point = volume.mount_point
      }
    )
    ]
  )

  user_data = join("\n", [
    var.user_data,
    file("${path.module}/user_data_scripts/reboot.sh")
    ]
  )

  instance_tags = merge(
    var.additional_tags,
    {
      Name        = local.tag_name
      Environment = var.tag_environment
      Hostname    = var.hostname
    },
  )
}

resource "aws_spot_instance_request" "instance" {

  placement_group = var.placement_group

  tags = local.instance_tags

  volume_tags = local.instance_tags

  wait_for_fulfillment = true

  instance_interruption_behavior = "stop"

  instance_type = var.type

  ami = var.ami

  key_name = var.key_name

  disable_api_termination = true

  ebs_optimized = true

  monitoring = true

  iam_instance_profile = var.iam_instance_profile

  subnet_id = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  user_data = local.volume_mounts == "" ? local.user_data : join("\n", [
    local.volume_mounts,
    local.user_data
    ]
  )

  user_data_replace_on_change = var.user_data_replace_on_change

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = var.encrypt_volumes
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_volumes
    content {
      device_name = ebs_block_device.value["name"]
      volume_type = ebs_block_device.value["type"]
      volume_size = ebs_block_device.value["size"]
      encrypted   = var.encrypt_volumes
    }
  }

}

resource "aws_ec2_tag" "instance" {
  for_each = local.instance_tags

  resource_id = aws_spot_instance_request.instance.spot_instance_id
  key         = each.key
  value       = each.value
}

data "aws_subnet" "instance" {
  id = var.subnet_id
}

resource "aws_ebs_volume" "raid_array" {
  count             = var.raid_array_size > 0 ? 10 : 0
  availability_zone = data.aws_subnet.instance.availability_zone
  size              = var.raid_array_size / 10
  encrypted         = var.encrypt_volumes
  type              = "gp3"
  tags = {
    Name = "${local.tag_name} Raid Array Disk ${count.index}"
  }
  lifecycle {
    replace_triggered_by = [aws_spot_instance_request.instance.spot_instance_id]
  }
}

resource "aws_volume_attachment" "raid_array" {
  count       = length(aws_ebs_volume.raid_array.*.id)
  volume_id   = aws_ebs_volume.raid_array[count.index].id
  instance_id = aws_spot_instance_request.instance.spot_instance_id
  device_name = "/dev/sd${substr("fghijklmnopqrstuvwxyz", count.index + 1, 1)}"
}
