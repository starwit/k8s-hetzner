variable "hcloud_token" {}
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