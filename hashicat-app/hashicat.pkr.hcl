packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "hashicat-aws"
}

variable "placeholder" {
  type    = string
  default = "placekitten.com"
}

variable "width" {
  type    = string
  default = "500"
}

variable "height" {
  type    = string
  default = "500"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

data "amazon-ami" "ubuntu-focal-eu" {
  region = "eu-west-2"
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "base_eu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami    = data.amazon-ami.ubuntu-focal-eu.id
  ssh_username  = "ubuntu"
  tags = {
    Name        = "hashicat-aws"
    environment = "production"
  }
  snapshot_tags = {
    environment = "production"
  }
}


build {
  name = "hashicat-aws"
  sources = [
    "source.amazon-ebs.base_eu"
  ]


  # Execute setup script
  provisioner "shell" {
    environment_vars = [
    "PLACEHOLDER=${var.placeholder}",
    "WIDTH=${var.width}",
    "HEIGHT=${var.height}"
  ]
    script = "setup.sh"
  }


  # HCP Packer settings
  hcp_packer_registry {
    bucket_name = "hashicat-aws"
    description = <<EOT
This is a Hashcat image base built on top of ubuntu 20.04.
    EOT

    bucket_labels = {
      "hashicat" = "aws",
      "ubuntu-version"  = "20.04"
    }
  }
}
