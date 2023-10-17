#_________________________________PRIVATE--MINIKUBE INSTANCE _____________________________________

resource "openstack_networking_network_v2" "my_network" {
  name           = "${var.project}_${var.username}-${var.environment_private}_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "my_private_subnet" {
  name       = "${var.project}_${var.username}-${var.environment_private}_subnet"
  network_id = openstack_networking_network_v2.my_network.id
  cidr       = local.KIS.network.private_cidr
}

resource "openstack_compute_instance_v2" "my_private_instance" {
  name            = "${var.project}_${var.username}--MINIKUBE_instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  #key_pair        = data.openstack_compute_keypair_v2.my_instance_keypair
  security_groups = ["default"]

  metadata = {
  }

  network {
    name = openstack_networking_network_v2.my_network.name
  }
}
#_________________________________PUBLIC--JUMP INSTANCE _____________________________________

resource "openstack_networking_network_v2" "external_network"{
    name = var.external_network_name
}
resource "openstack_compute_instance_v2" "my_public_instance" {
  name            = "${var.project}_${var.username}--JUMP_instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  #key_pair        = data.openstack_compute_keypair_v2.my_instance_keypair
  security_groups = ["default"]

  metadata = {
  }

  network {
    name = openstack_networking_network_v2.external_network.name
  }
}

#____________________________KEY PAIRS_______________________________________
resource "openstack_compute_keypair_v2" "my_instance_keypair" {
  name = "${var.project}_${var.username}-keypair"
}