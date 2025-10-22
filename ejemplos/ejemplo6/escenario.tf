##############################################
# escenario.tf — Definición del escenario
##############################################

locals {

  ##############################################
  # Redes a crear
  ##############################################

  networks = {
    nat-dhcp = {
      name      = "nat-dhcp"
      mode      = "nat"
      domain    = "example.com"
      addresses = ["192.168.100.0/24"]
      bridge    = "virbr30"
      dhcp      = true
      dns       = true
      autostart = true
    }

    muy-aislada = {
      name      = "muy-aislada"
      mode      = "none" # sin conectividad
      bridge    = "virbr31"
      autostart = true
    }

    nat-ubuntu = {  # MOVIDO DENTRO de networks
      name      = "nat-ubuntu"
      mode      = "nat"
      domain    = "ubuntu.local"
      addresses = ["192.168.200.0/24"]
      bridge    = "virbr32"
      dhcp      = true
      dns       = true
      autostart = true
    }
  }

  ##############################################
  # Máquinas virtuales a crear
  ##############################################

  servers = {
    server1 = {
      name       = "server1"
      memory     = 1024
      vcpu       = 2
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "nat-dhcp", wait_for_lease = true },
        { network_name = "muy-aislada" }
      ]

      disks = [
        { name = "data", size = 5 * 1024 * 1024 * 1024 }
      ]

      user_data      = "${path.module}/cloud-init/server1/user-data.yaml"
      network_config = "${path.module}/cloud-init/server1/network-config.yaml"
    }

    server2 = {
      name       = "server2"
      memory     = 1024
      vcpu       = 2
      base_image = "ubuntu2404-base.qcow2"

      networks = [
        { network_name = "muy-aislada" }
      ]

      user_data      = "${path.module}/cloud-init/server2/user-data.yaml"
      network_config = "${path.module}/cloud-init/server2/network-config.yaml"
    }

    ubuntu-server = { 
      name       = "ubuntu-server"
      memory     = 1024
      vcpu       = 2
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "nat-ubuntu", wait_for_lease = true },
        { network_name = "muy-aislada" }
      ]

      user_data      = "${path.module}/cloud-init/ubuntu-server/user-data.yaml"
      network_config = "${path.module}/cloud-init/ubuntu-server/network-config.yaml"
    }
  }
} 
