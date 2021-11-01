# Install Kubernetes Cluster on Hetzner with Terraform and GitHubActions

## Installation Hints

These scripts create or destroy an Kubernetes Cluster on Hetzner. For that, the following Github Actions can be used:

* [Create Kubernetes Cluster on Hetzner](https://github.com/starwit/infrastructure/actions/workflows/tf-apply-k8s-hetzner.yml)
* [Destroy Kubernetes on Hetzner](https://github.com/starwit/infrastructure/actions/workflows/tf-destroy-k8s-hetzner.yml)

There is the possibility to create clusters for different terraform workspaces / environments. It is recommanded to use the following:
* dev (default in github action)
* int
* prod

The Installation is done by using kubeadm. See https://kubernetes.io/docs/setup/production-environment/ for detailed information.

Due to missing possibilities to save terraform state on cloud, it is saved inside a private repository.

## Update Cluster

Updating the Cluster is not yet implemented via GitHub and has to be done by following the manual under:
* https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

Additionally, you should check and upgrade helm if needed: 

```bash
apt upgrade helm
```

## Links
* https://community.hetzner.com/tutorials/install-kubernetes-cluster
* https://community.hetzner.com/tutorials/howto-hcloud-terraform
* https://github.com/gammpamm, https://github.com/gammpamm/hcloud-k8s

