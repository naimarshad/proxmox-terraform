terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "proxmox_api_url" {
    type = string 
}

variable "proxmox_api_user" {
    type = string
    sensitive = true
}

variable "proxmox_api_password" {
    type = string
    sensitive = true
}

variable "pvt_key" {
    type = string
}
variable "pub_key" {
    type = string
}


provider "proxmox" {
  pm_api_url  = var.proxmox_api_url
  pm_user    = var.proxmox_api_user
  pm_password = var.proxmox_api_password
  pm_tls_insecure    = "true"  # Set to true if using self-signed SSL certificates
#   pm_debug = true
}