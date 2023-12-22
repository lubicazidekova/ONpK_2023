
#_________________________________PUBLIC-- EXTERNAL NETWROK + JUMP INSTANCE _____________________________________

resource "openstack_networking_network_v2" "external_network"{
    name = "${var.project}_${var.username}-${var.external_network_name}"
}

resource "openstack_networking_subnet_v2" "external_network_subnet" {
  name       = "${var.project}_${var.username}-${var.external_network_subnet_name}"
  network_id = openstack_networking_network_v2.public_network.id
  cidr       = local.KIS.network.cidr
  ip_version = 4
}
# FLOATING IP for JUMP instance
resource "openstack_networking_floatingip_v2" "JUMP_instance_floating_IP" {
  pool = "public"
}

resource "openstack_compute_instance_v2" "JUMP_instance" {
  name            = "${var.project}_${var.username}--JUMP_instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  #key_pair        = data.openstack_compute_keypair_v2.my_instance_keypair
  security_groups = ["default"]

  network {
    name = openstack_networking_network_v2.external_network_subnet.name
  }
  network {
    name = openstack_networking_network_v2.private_network_subnet.name

  }
  
}
resource "openstack_compute_floatingip_associate_v2" "JUMP_instance_floating_IP_association" {
  floating_ip = openstack_networking_floatingip_v2.JUMP_instance_floating_IP.address
  instance_id = openstack_compute_instance_v2.JUMP_instance.id
  fixed_ip    = openstack_compute_instance_v2.JUMP_instance.1.fixed_ip
}

#_________________________________PRIVATE--MINIKUBE INSTANCE _____________________________________

resource "openstack_networking_network_v2" "private_network" {
  name           = "${var.project}_${var.username}-${var.private_network_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_subnet" {
  name       = "${var.project}_${var.username}-${var.private_network_subnet_name}"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = local.KIS.network.private_cidr
  ip_version = 4
}

resource "openstack_compute_instance_v2" "MINIKUBE_private_instance" {
  name            = "${var.project}_${var.username}--MINIKUBE_instance"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  #key_pair        = data.openstack_compute_keypair_v2.my_instance_keypair
  security_groups = ["default"]

  network {
    name = openstack_networking_subnet_v2.private_network_subnet.name
  }
}
#___________________________ROUTER_____________________________________________
# Create router and connect public and private networks
resource "openstack_networking_router_v2" "router" {
  name = var.router.name
}

resource "openstack_networking_router_interface_v2" "router_interface_public" {
  router_id     = openstack_networking_router_v2.router.id
  subnet_id     = openstack_networking_subnet_v2.public_network_subnet.id
}

resource "openstack_networking_router_interface_v2" "router_interface_private" {
  router_id     = openstack_networking_router_v2.router.id
  subnet_id     = openstack_networking_subnet_v2.private_network_subnet.id
}

#____________________________KEY PAIRS_______________________________________
resource "openstack_compute_keypair_v2" "my_instance_keypair" {
  name = "${var.project}_${var.username}-keypair"
}