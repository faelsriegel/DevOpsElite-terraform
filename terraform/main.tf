terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.25.2"
    }
  }
}
provider "digitalocean" {
  token = "dop_v1_b762a3f0e0a54a881c87a958699e04b8be1b3102230b8f365879dea239c7381c"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins-vm"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "web" {
  image  = "ubuntu-18-04-x64"
  name   = "web-1"
  region = "nyc2"
  size   = "s-1vcpu-1gb"
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = ""

}

variable "do_token" {
  default = ""

}

variable "ssh_key_name" {
  default = ""

}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "foo" {
  content  = "digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config"
  filename = "kube_config_yaml"
}
