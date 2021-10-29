resource "hcloud_network" "internalnet" {
  name = "${terraform.workspace}-internalnet"
  ip_range = "192.168.2.0/24"
}

resource "hcloud_network_subnet" "internalsubnet" {
  network_id = "${hcloud_network.internalnet.id}"
  type = "server"
  network_zone = "eu-central"
  ip_range   = "192.168.2.0/28"
}
