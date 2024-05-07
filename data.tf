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