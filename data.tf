data "openstack_images_image_v2" "image" {
  name = local.KIS.instance.image.ubuntu.name
}

data "openstack_compute_flavor_v2" "flavor" {
  name = local.KIS.instance.flavor_name
}

data "openstack_networking_network_v2" "private_network"{
    name = openstack_networking_network_v2.my_network.name
}

