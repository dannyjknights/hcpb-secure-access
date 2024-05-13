
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_user" "boundary" {
  user_name = var.boundary_aws_user
}

data "aws_s3_bucket" "boundary_session_recording_bucket" {
  bucket = var.s3_bucket_name
}

# Data block to grab current IP and add into SG rules
data "http" "current" {
  url = "https://api.ipify.org"
}

data "aws_ami" "linux" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "description"
    values = ["Amazon Linux 2023*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

//Configure the EC2 host to trust Vault as the CA
data "cloudinit_config" "ssh_trusted_ca" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    sudo curl -o /etc/ssh/trusted-user-ca-keys.pem \
    --header "X-Vault-Namespace: admin" \
    -X GET \
    ${var.vault_addr}/v1/ssh-client-signer/public_key
    sudo echo TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem >> /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    sudo adduser admin_user
    sudo adduser danny
    EOF
  }
}

# Windows Target
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

/* This data block pulls in all the different parts of the configuration to be deployed.
These are executed in the order that they are written. Firstly, the boundary-worker binary
will be called. Secondly, the configuration specified in the locals block will be called.
Lastly the boundary-worker process is started using the pki-worker.hcl file.
*/
data "cloudinit_config" "boundary_self-managed_worker" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      sudo yum install -y shadow-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      sudo yum -y install boundary-enterprise
      curl 'https://api.ipify.org?format=txt' > /tmp/ip
      sudo mkdir /etc/boundary.d/sessionrecord
  EOF
  }
  part {
    content_type = "text/cloud-config"
    content      = yamlencode(local.cloudinit_config_boundary_self-managed_worker)
  }
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    sudo boundary server -config="/etc/boundary.d/pki-worker.hcl"
    EOF
  }
}