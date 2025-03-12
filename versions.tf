terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hyperfabric = {
      source  = "CiscoDevNet/hyperfabric"
      version = ">= 0.1.0"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.5"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}
