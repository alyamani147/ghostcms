variable "key_name" {
  description = "The key pair name for the EC2 instance."
  # Update with your key pair name
  default     = "ghostsshkey"
}

variable "subnet_id_ghost" {
  description = "The ID of the subnet in which to deploy the EC2 instance."
  # Update with your subnet ID
  default     = "subnet-04ddb4153c6cb3123"
}

variable "ami_id_ghost" {
  description = "The ID of the base AMI."
  # Update with the ID of the desired base AMI
  default     = "ami-0e80cdc14ed2f397b"
}

variable "instance_type_t2mirco" {
  description = "The type of EC2 instance."
  default     = "t2.micro"
}

variable "aws_region_eu-central-1" {
  description = "The AWS region to deploy resources."
  default     = "eu-central-1"
}