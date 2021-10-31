variable "HCLOUD_TOKEN" {}

variable "ssh_public_key" {} # public ssh key without pw to enable tf to run stuff
variable "ssh_private_key" {} # private ssh key to enable tf...
variable "node_image" {
  default = "ubuntu-18.04"
}

variable "master_type" {
  default = "cx21"
}

variable "worker_type" {
  default = "cx11"
}
variable "workers" {
  default = "0"
}