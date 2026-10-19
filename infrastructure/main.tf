terraform {
  required_version = ">= 1.13.1"
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.14.0"
    }

        random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}