resource "hcloud_server" "master" {
  name = "${terraform.workspace}-k8s-master"
  image = "${var.node_image}"
  server_type = "${var.master_type}"
  ssh_keys = [ "${hcloud_ssh_key.terraformremotekey.id}"]

  connection {
    type="ssh"
    host = "${hcloud_server.master.ipv4_address}"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/master.sh"
    destination = "/root/master.sh"
  }

  # config file for kubeadm init
  provisioner "file" {
    source      = "${path.module}/scripts/kubeconf.yaml"
    destination = "/root/kubeconf.yaml"
  }

  #flannel config
  provisioner "file" {
    source      = "${path.module}/scripts/kube-flannel.yaml"
    destination = "/root/kube-flannel.yaml"
  }

  # will be called on every node completion
  provisioner "file" {
    source      = "${path.module}/scripts/addNodeToMaster.sh"
    destination = "/root/addNodeToMaster.sh"
  }

  # bash stuff
  provisioner "file" {
    source      = "${path.module}/scripts/bash-config.sh"
    destination = "/root/bash-config.sh"
  }

  provisioner "file" {
    source      = "${path.module}/kubernetes-post-install-config"
    destination = "/root/"
  }

  provisioner "file" {
    source      = "${path.module}/app-deployment"
    destination = "/root/"
  }
}

resource "hcloud_server_network" "srvnetworkmaster" {
  server_id = "${hcloud_server.master.id}"
  network_id = "${hcloud_network.internalnet.id}"

  connection {
    type="ssh"
    host = "${hcloud_server.master.ipv4_address}"
    private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/master.sh 192.168.2.2 ${hcloud_server.master.ipv4_address} ${hcloud_floating_ip.public_ip.ip_address}"]
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/copy_local.sh"

    environment = {
      SSH_PRIVATE_KEY 	= "${var.ssh_private_key}"
      SSH_CONN   				= "root@${hcloud_server.master.ipv4_address}"
      COPY_TO_LOCAL    	= "creds/"
    }
  }
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

