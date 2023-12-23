data "openstack_images_image_v2" "image" {
  name = local.KIS.instance.image.debian.name
}

data "openstack_compute_flavor_v2" "flavor" {
  name = local.KIS.instance.flavor_name
}

data "openstack_compute_keypair_v2" "my_instance_keypair" {
  name = openstack_compute_keypair_v2.instance_keypair.name
}

data "template_file" "docker_minikube_instance" {
  template = file("cloud-init.yaml")
}