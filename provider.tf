terraform {
  required_providers {
    morpheus = {
      source  = "gomorpheus/morpheus"
      version = "0.7.0"
    }
  }
}

provider "morpheus" {
  url          = var.morpheus_url
  access_token = var.morpheus_access_token
}
