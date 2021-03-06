terraform {
  cloud {
    organization = "greenreedtech"

    workspaces {
      name = "morpheus-terraform-config"
    }
  }
  required_providers {
    morpheus = {
      source  = "morpheusdata.com/gomorpheus/morpheus"
      version = "0.4.3"
    }
  }
}

provider "morpheus" {
  url          = var.morpheus_url
  access_token = var.morpheus_access_token
}
