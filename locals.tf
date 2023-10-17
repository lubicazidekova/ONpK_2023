#LOCAL 

locals {
  kis_os_region      = "RegionOne"
  kis_os_auth_url    = "https://158.193.152.44:5000/v3/"
  kis_os_domain_name = "admin_domain"

  kis_os_endpoint_overrides = {
    compute = "https://158.193.152.44:8774/v2.1/"
    image   = "https://158.193.152.44:9292/v2.0/"
    network = "https://158.193.152.44:9696/v2.0/"
  }

  KIS = {
    network = {
      cidr = "158.193.0.0/16",
      private_cidr ="10.0.0.0/8"
    },
    instance = {
      flavor_name = "2c2r20d"
      image = {
        ubuntu = {
          name = "ubuntu-22.04-KIS"
        },
        debian = {
          name = "debian-12-kis"
        }
      }
    }
  }
}