
#________________________________PRIVATE--MINIKUBE INSTANCE _____________________________________

resource "openstack_networking_network_v2" "private_network" {
  name           = var.private_network_name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_subnet" {
  name       = var.private_network_subnet_name
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = local.KIS.network.private_cidr
  ip_version = 4
}

resource "openstack_compute_instance_v2" "MINIKUBE_private_instance" {
  name            = var.MINIKUBE_instance_name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = data.openstack_compute_keypair_v2.my_instance_keypair.name
  security_groups = ["default"]
  depends_on = [ openstack_networking_subnet_v2.private_network_subnet ]
  network {
    name = var.private_network_name

  }
  user_data = data.template_file.docker_minikube_instance.rendered
}


#_________________________________PUBLIC-- EXTERNAL NETWROK + JUMP INSTANCE _____________________________________

#resource "openstack_networking_network_v2" "external_network"{
#    name = var.external_network_name
#}

#resource "openstack_networking_subnet_v2" "external_network_subnet" {
#  name       = var.external_network_subnet_name
#  network_id = openstack_networking_network_v2.external_network.id
 # cidr       = local.KIS.network.cidr
 # ip_version = 4
#}
# FLOATING IP for JUMP instance
resource "openstack_networking_floatingip_v2" "JUMP_instance_floating_IP" {
  pool = var.external_network_name
}

resource "openstack_compute_instance_v2" "JUMP_instance" {
  name            = var.JUMP_instance_name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = data.openstack_compute_keypair_v2.my_instance_keypair.name
  depends_on      = [ openstack_networking_subnet_v2.private_network_subnet]
  security_groups = ["default"]


 
  network {
    name = var.external_network_name
     
   }
  network {
    name = var.private_network_name

  }
  
}
resource "openstack_compute_floatingip_associate_v2" "JUMP_instance_floating_IP_association" {
  floating_ip = openstack_networking_floatingip_v2.JUMP_instance_floating_IP.address
  instance_id = openstack_compute_instance_v2.JUMP_instance.id
}

#_____________________________ROUTER__________________________________________
# Create router and connect public and private networks
resource "openstack_networking_router_v2" "router" {
  name = var.router_name
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id     = openstack_networking_router_v2.router.id
  subnet_id     = openstack_networking_subnet_v2.private_network_subnet.id
}

#____________________________KEY PAIRS_______________________________________
resource "openstack_compute_keypair_v2" "instance_keypair" {
  name = "${var.project}_${var.username}-keypair"
}

#____________________________SECURITY GROUPS_________________________________

#---------------------------Security rules for JUMP instance-----------------
resource "openstack_networking_secgroup_v2" "JUMP_instance_security_group" {
  name        =  var.JUMP_SG_name
  description = "Security group for my JUMP instance"
}

#Allow SSH and TCP connection just from UNIVERSITY network
resource "openstack_networking_secgroup_rule_v2" "SG_SSH_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
 
  remote_ip_prefix  = local.KIS.network.cidr
  security_group_id = openstack_networking_secgroup_v2.JUMP_instance_security_group.id
}

#Allow ICMP just from UNIVERSITY network
resource "openstack_networking_secgroup_rule_v2" "SG_ICMP_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = local.KIS.network.cidr
  security_group_id = openstack_networking_secgroup_v2.JUMP_instance_security_group.id
}
#---------------------------Security rules for MINIKUBE instance-----------------
resource "openstack_networking_secgroup_v2" "MINIKUBE_instance_security_group" {
  name        =  var.MINIKUBE_SG_name
  description = "Security group for my MINIKUBE instance"
}

#Allow SSH and other TCP connection just from my JUMP instance 
resource "openstack_networking_secgroup_rule_v2" "SG_TCP_rule_inside" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  #remote_ip_prefix  = join("/", [, "32"])
  security_group_id = openstack_networking_secgroup_v2.MINIKUBE_instance_security_group.id
}