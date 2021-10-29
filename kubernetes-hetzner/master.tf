resource "hcloud_server" "master" {
  name = "${terraform.workspace}-k8s-master"
  image = "${var.node_image}"
  server_type = "${var.master_type}"
}

resource "hcloud_server_network" "srvnetworkmaster" {
  server_id = "${hcloud_server.master.id}"
  network_id = "${hcloud_network.internalnet.id}"
}

#resource "hcloud_volume" "k8storage" {
#  name = "nodevolume"
#  size = 10
#  server_id = "${hcloud_server.master.id}"
#  automount = "true"
#  format = "ext4"
#}

resource "hcloud_floating_ip" "public_ip" {
  name = "${terraform.workspace}-k8s-floating-ip"
  server_id = "${hcloud_server.master.id}"
  type = "ipv4"
}

resource "hcloud_floating_ip_assignment" "master" {
  server_id = "${hcloud_server.master.id}"
  floating_ip_id= "${hcloud_floating_ip.public_ip.id}"
}

