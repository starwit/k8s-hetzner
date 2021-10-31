terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.24.1"
    }
  }
}

provider "hcloud" {
  token = "${var.HCLOUD_TOKEN}"
}

resource "hcloud_ssh_key" "terraformremotekey" {
  name = "${terraform.workspace}-k8s-tf-key"
  public_key = "${var.ssh_public_key}"
}
