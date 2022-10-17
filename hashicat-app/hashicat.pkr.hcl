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
  default = "placecats.com"
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

data "amazon-ami" "ubuntu-focal-east" {
  region = "us-east-2"
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "basic-example-east" {
  region         = "us-east-2"
  source_ami     = data.amazon-ami.ubuntu-focal-east.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "${var.ami_prefix}-${local.timestamp}"
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
    "source.amazon-ebs.basic-example-east"
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
      "hashicat"       = "aws",
      "ubuntu-version" = "20.04"
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
}
