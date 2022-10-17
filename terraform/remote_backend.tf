terraform {
  cloud {
    organization = "andrepimentel-test"
    hostname = "app.terraform.io" 

    workspaces {
      tags = ["hcp-packer-hashicat-aws"]
    }
  }
}