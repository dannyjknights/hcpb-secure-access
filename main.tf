# Declare the required providers and their version constraints for this Terraform configuration
terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = ">=1.1.15"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.4.2"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.4"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">=0.89.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.5"
    }
  }
}

# Declare the provider for the AWS resource to be managed by Terraform
provider "aws" {
  region = "eu-west-1"
}

provider "vault" {
}

# Declare the provider for the HashiCorp Boundary resource to be managed by Terraform
provider "boundary" {
  # Use variables to provide values for the provider configuration
  addr                   = var.boundary_addr
  auth_method_login_name = var.password_auth_method_login_name
  auth_method_password   = var.password_auth_method_password

}

