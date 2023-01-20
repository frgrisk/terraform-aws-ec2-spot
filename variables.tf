variable "tag_environment" {
  description = "The name of the environment to use in resource tagging"
  type        = string
}

variable "tag_name" {
  description = "The name tag of the instance"
  type        = string
  default     = ""
}

variable "placement_group_name" {
  description = "The name of the placement group to place the instance in"
  type        = string
}

variable "subnet_id" {
  description = "The subnet to use for the instance"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
}

variable "type" {
  description = "The type of instance to use"
  type        = string
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}

variable "hostname" {
  description = "The hostname of the instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to use for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs to use for the instance"
  type        = list(string)
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
}

variable "raid_array_size" {
  description = "Size in GB of RAID array"
  type        = number
  default     = 0
}

variable "root_volume_size" {
  description = "Size in GB of RAID array"
  type        = number
  default     = 30
}

variable "additional_volumes" {
  description = "Additional volumes to create and attach to the instance"
  type        = map(map(string))
  default     = {}
}

variable "user_data_replace_on_change" {
  description = "Replace the instance if the instance user data changes"
  type        = bool
  default     = true
}
