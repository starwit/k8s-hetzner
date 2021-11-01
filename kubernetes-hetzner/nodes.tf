resource "hcloud_server" "node" {
  count       = "${var.workers}"
  name        = "${terraform.workspace}-node-${count.index}"
  server_type = "${var.worker_type}"
  image       = "${var.node_image}"
  depends_on  = [hcloud_server.master, hcloud_server_network.srvnetworkmaster]
  ssh_keys = [ "${hcloud_ssh_key.terraformremotekey.id}"]

  connection {
    type = "ssh"
    host = "(self.private_ip)"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/daemon.json"
    destination = "/root/daemon.json"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "${path.module}/creds/cluster_join"
    destination = "/tmp/cluster_join"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/node.sh"
    destination = "/root/node.sh"
  }

  # bash stuff
  provisioner "file" {
    source      = "${path.module}/scripts/bash-config.sh"
    destination = "/root/bash-config.sh"
  }
}

resource "hcloud_server_network" "firewall-node" {
  depends_on = [hcloud_server.node]
  count = "${var.workers}"
  server_id = "${element(hcloud_server.node.*.id, count.index)}"
  network_id = "${hcloud_network.internalnet.id}"
  ip = "${cidrhost(hcloud_network_subnet.internalsubnet.ip_range, count.index + 3)}"

  connection {
    type="ssh"
    host = "${hcloud_server.master.ipv4_address}"
    private_key = "${var.ssh_private_key}"
  }  

  provisioner "remote-exec" {
    inline = ["bash /root/addNodeToMaster.sh ${element(hcloud_server.node.*.ipv4_address, count.index)}"]
  }
}

resource "hcloud_server_network" "srvnetworknode1" {
  depends_on = [hcloud_server.node]
  count = "${var.workers}"
  server_id = "${element(hcloud_server.node.*.id, count.index)}"
  network_id = "${hcloud_network.internalnet.id}"
  ip = "${cidrhost(hcloud_network_subnet.internalsubnet.ip_range, count.index + 3)}"

  connection {
    type="ssh"
    host = "${element(hcloud_server.node.*.ipv4_address, count.index)}"
    private_key = "${var.ssh_private_key}"
  }  

  provisioner "remote-exec" {
    inline = ["bash /root/node.sh ${cidrhost(hcloud_network_subnet.internalsubnet.ip_range, count.index + 3)} ${hcloud_server.master.ipv4_address}"]
  }
}
