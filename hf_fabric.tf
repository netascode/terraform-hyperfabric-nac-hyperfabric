resource "hyperfabric_fabric" "fabric" {
  for_each = { for fabric in try(local.hyperfabric.fabrics, []) : fabric.name => fabric }

  name        = each.key
  description = try(each.value.description, local.defaults.hyperfabric.fabrics.description, null)
  address     = try(each.value.address, local.defaults.hyperfabric.fabrics.address, null)
  city        = try(each.value.city, local.defaults.hyperfabric.fabrics.city, null)
  country     = try(each.value.country, local.defaults.hyperfabric.fabrics.country, null)
  location    = try(each.value.location, local.defaults.hyperfabric.fabrics.location, null)
  labels      = try(each.value.labels, local.defaults.hyperfabric.fabrics.labels, null)
  annotations = [for key, value in try(each.value.annotations, {}) : {
    name  = key
    value = value
  }]
}

locals {
  fabric_nodes = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for node in try(fabric.nodes, []) : {
        key         = format("%s/%s", fabric.name, node.name)
        fabric_id   = hyperfabric_fabric.fabric[fabric.name].id
        name        = node.name
        description = try(node.description, local.defaults.hyperfabric.fabrics.nodes.description, null)
        model_name  = try(node.model, local.defaults.hyperfabric.fabrics.nodes.model, null)
        roles       = try(node.roles, local.defaults.hyperfabric.fabrics.nodes.roles, null)
        location    = try(node.location, local.defaults.hyperfabric.fabrics.nodes.location, null)
        labels      = try(node.labels, local.defaults.hyperfabric.fabrics.nodes.labels, null)
        annotations = [for key, value in try(node.annotations, {}) : {
          name  = key
          value = value
        }]
      }
    ]
  ])
}

resource "hyperfabric_node" "node" {
  for_each = { for node in local.fabric_nodes : node.key => node }

  fabric_id   = each.value.fabric_id
  name        = each.value.name
  description = each.value.description
  model_name  = each.value.model_name
  roles       = each.value.roles
  location    = each.value.location
  labels      = each.value.labels
  annotations = each.value.annotations
}

locals {
  fabric_connections = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for connection in try(fabric.connections, []) : {
        key         = format("%s/%s/%s/%s/%s", fabric.name, connection.local_node, connection.local_port, connection.remote_node, connection.remote_port)
        fabric_id   = hyperfabric_fabric.fabric[fabric.name].id
        description = try(connection.description, local.defaults.hyperfabric.fabrics.connections.description, null)
        pluggable   = try(connection.pluggable, local.defaults.hyperfabric.fabrics.connections.pluggable, null)
        local = {
          node_id   = hyperfabric_node.node["${fabric.name}/${connection.local_node}"].node_id
          port_name = connection.local_port
        }
        remote = {
          node_id   = hyperfabric_node.node["${fabric.name}/${connection.remote_node}"].node_id
          port_name = connection.remote_port
        }
      }
    ]
  ])
}

resource "hyperfabric_connection" "connection" {
  for_each = { for connection in local.fabric_connections : connection.key => connection }

  fabric_id   = each.value.fabric_id
  description = each.value.description
  pluggable   = each.value.pluggable
  local       = each.value.local
  remote      = each.value.remote
}

locals {
  fabric_nodes_management_port = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for node in try(fabric.nodes, []) : {
        key              = format("%s/%s", fabric.name, node.name)
        node_id          = hyperfabric_node.node[format("%s/%s", fabric.name, node.name)].node_id
        name             = try(node.management_port.name, local.defaults.hyperfabric.fabrics.nodes.management_port.name, null)
        description      = try(node.management_port.description, local.defaults.hyperfabric.fabrics.nodes.management_port.description, null)
        cloud_urls       = try(node.management_port.cloud_urls, local.defaults.hyperfabric.fabrics.nodes.management_port.cloud_urls, null)
        ipv4_config_type = try(node.management_port.ipv4_address, null) != null ? "CONFIG_TYPE_STATIC" : "CONFIG_TYPE_DHCP"
        ipv4_address     = try(node.management_port.ipv4_address, local.defaults.hyperfabric.fabrics.nodes.management_port.ipv4_address, null)
        ipv4_gateway     = try(node.management_port.ipv4_gateway, local.defaults.hyperfabric.fabrics.nodes.management_port.ipv4_gateway, null)
        ipv6_config_type = try(node.management_port.ipv6_address, null) != null ? "CONFIG_TYPE_STATIC" : "CONFIG_TYPE_DHCP"
        ipv6_address     = try(node.management_port.ipv6_address, local.defaults.hyperfabric.fabrics.nodes.management_port.ipv6_address, null)
        ipv6_gateway     = try(node.management_port.ipv6_gateway, local.defaults.hyperfabric.fabrics.nodes.management_port.ipv6_gateway, null)
        dns_addresses    = try(node.management_port.dns_addresses, local.defaults.hyperfabric.fabrics.nodes.management_port.dns_addresses, null)
        ntp_addresses    = try(node.management_port.ntp_addresses, local.defaults.hyperfabric.fabrics.nodes.management_port.ntp_addresses, null)
        no_proxy         = try(node.management_port.no_proxy, local.defaults.hyperfabric.fabrics.nodes.management_port.no_proxy, null)
        proxy_address    = try(node.management_port.proxy_address, local.defaults.hyperfabric.fabrics.nodes.management_port.proxy_address, null)
        proxy_username   = try(node.management_port.proxy_username, local.defaults.hyperfabric.fabrics.nodes.management_port.proxy_username, null)
        proxy_password   = try(node.management_port.proxy_password, local.defaults.hyperfabric.fabrics.nodes.management_port.proxy_password, null)
      } if try(node.management_port, null) != null
    ]
  ])
}

resource "hyperfabric_node_management_port" "node_management_port" {
  for_each = { for port in local.fabric_nodes_management_port : port.key => port }

  node_id          = each.value.node_id
  name             = each.value.name
  description      = each.value.description
  cloud_urls       = each.value.cloud_urls
  ipv4_config_type = each.value.ipv4_config_type
  ipv4_address     = each.value.ipv4_address
  ipv4_gateway     = each.value.ipv4_gateway
  ipv6_config_type = each.value.ipv6_config_type
  ipv6_address     = each.value.ipv6_address
  ipv6_gateway     = each.value.ipv6_gateway
  dns_addresses    = each.value.dns_addresses
  ntp_addresses    = each.value.ntp_addresses
  no_proxy         = each.value.no_proxy
  proxy_address    = each.value.proxy_address
  proxy_username   = each.value.proxy_username
  proxy_password   = each.value.proxy_password
}

locals {
  fabric_vrfs = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for vrf in try(fabric.vrfs, []) : {
        key         = format("%s/%s", fabric.name, vrf.name)
        fabric_id   = hyperfabric_fabric.fabric[fabric.name].id
        name        = vrf.name
        description = try(vrf.description, local.defaults.hyperfabric.fabrics.vrfs.description, null)
        asn         = try(vrf.asn, local.defaults.hyperfabric.fabrics.vrfs.asn, null)
        vni         = try(vrf.vni, local.defaults.hyperfabric.fabrics.vrfs.vni, null)
        labels      = try(vrf.labels, local.defaults.hyperfabric.fabrics.vrfs.labels, null)
        annotations = [for key, value in try(vrf.annotations, {}) : {
          name  = key
          value = value
        }]
      }
    ]
  ])
}

resource "hyperfabric_vrf" "vrf" {
  for_each = { for vrf in local.fabric_vrfs : vrf.key => vrf }

  fabric_id   = each.value.fabric_id
  name        = each.value.name
  description = each.value.description
  asn         = each.value.asn
  vni         = each.value.vni
  labels      = each.value.labels
  annotations = each.value.annotations
}

locals {
  fabric_node_loopbacks = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for node in try(fabric.nodes, []) : [
        for loopback in try(node.loopbacks, []) : {
          key          = format("%s/%s/%s", fabric.name, node.name, loopback.name)
          node_id      = hyperfabric_node.node[node.name].node_id
          name         = loopback.name
          description  = try(loopback.description, local.defaults.hyperfabric.fabrics.nodes.loopbacks.description, null)
          ipv4_address = try(loopback.ipv4_address, local.defaults.hyperfabric.fabrics.nodes.loopbacks.ipv4_address, null)
          ipv6_address = try(loopback.ipv6_address, local.defaults.hyperfabric.fabrics.nodes.loopbacks.ipv6_address, null)
          vrf_id       = try(hyperfabric_vrf.vrf[loopback.vrf].vrf_id, null)
          labels       = try(loopback.labels, local.defaults.hyperfabric.fabrics.nodes.loopbacks.labels, null)
          annotations = [for key, value in try(loopback.annotations, {}) : {
            name  = key
            value = value
          }]
        }
      ]
    ]
  ])
}

resource "hyperfabric_node_loopback" "node_loopback" {
  for_each = { for loopback in local.fabric_node_loopbacks : loopback.key => loopback }

  node_id      = each.value.node_id
  name         = each.value.name
  description  = each.value.description
  ipv4_address = each.value.ipv4_address
  ipv6_address = each.value.ipv6_address
  vrf_id       = each.value.vrf_id
  labels       = each.value.labels
  annotations  = each.value.annotations
}

locals {
  fabric_node_ports = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for node in try(fabric.nodes, []) : [
        for port in try(node.ports, []) : {
          key                = format("%s/%s/%s", fabric.name, node.name, port.name)
          node_id            = hyperfabric_node.node[node.name].node_id
          name               = port.name
          roles              = try(port.roles, local.defaults.hyperfabric.fabrics.nodes.ports.roles, null)
          description        = try(port.description, local.defaults.hyperfabric.fabrics.nodes.ports.description, null)
          enabled            = try(port.enabled, local.defaults.hyperfabric.fabrics.nodes.ports.enabled, null)
          ipv4_addresses     = try(port.ipv4_addresses, local.defaults.hyperfabric.fabrics.nodes.ports.ipv4_addresses, null)
          ipv6_addresses     = try(port.ipv6_addresses, local.defaults.hyperfabric.fabrics.nodes.ports.ipv6_addresses, null)
          prevent_forwarding = try(port.prevent_forwarding, local.defaults.hyperfabric.fabrics.nodes.ports.prevent_forwarding, null)
          vrf_id             = try(hyperfabric_vrf.vrf[port.vrf].vrf_id, null)
          labels             = try(port.labels, local.defaults.hyperfabric.fabrics.nodes.ports.labels, null)
          annotations = [for key, value in try(port.annotations, {}) : {
            name  = key
            value = value
          }]
        }
      ]
    ]
  ])
}

resource "hyperfabric_node_port" "node_port" {
  for_each = { for port in local.fabric_node_ports : port.key => port }

  node_id            = each.value.node_id
  name               = each.value.name
  roles              = each.value.roles
  description        = each.value.description
  enabled            = each.value.enabled
  ipv4_addresses     = each.value.ipv4_addresses
  ipv6_addresses     = each.value.ipv6_addresses
  prevent_forwarding = each.value.prevent_forwarding
  vrf_id             = each.value.vrf_id
  labels             = each.value.labels
  annotations        = each.value.annotations
}

locals {
  fabric_node_port_sub_interfaces = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for node in try(fabric.nodes, []) : [
        for port in try(node.ports, []) : [
          for sub in try(port.sub_interfaces, []) : {
            key            = format("%s/%s/%s/%s", fabric.name, node.name, port.name, sub.id)
            node_id        = hyperfabric_node.node[node.name].node_id
            name           = "${port.name}.${sub.id}"
            description    = try(sub.description, local.defaults.hyperfabric.fabrics.nodes.ports.sub_interfaces.description, null)
            enabled        = try(sub.enabled, local.defaults.hyperfabric.fabrics.nodes.ports.sub_interfaces.enabled, null)
            ipv4_addresses = try(sub.ipv4_addresses, local.defaults.hyperfabric.fabrics.nodes.ports.sub_interfaces.ipv4_addresses, null)
            ipv6_addresses = try(sub.ipv6_addresses, local.defaults.hyperfabric.fabrics.nodes.ports.sub_interfaces.ipv6_addresses, null)
            vlan_id        = try(sub.vlan_id, local.defaults.hyperfabric.fabrics.nodes.ports.sub_interfaces.vlan_id, null)
            vrf_id         = try(hyperfabric_vrf.vrf[sub.vrf].vrf_id, null)
            labels         = try(sub.labels, local.defaults.hyperfabric.fabrics.nodes.ports.sub_interfaces.labels, null)
            annotations = [for key, value in try(sub.annotations, {}) : {
              name  = key
              value = value
            }]
          }
        ]
      ]
    ]
  ])
}

resource "hyperfabric_node_sub_interface" "node_sub_interface" {
  for_each = { for sub in local.fabric_node_port_sub_interfaces : sub.key => sub }

  node_id        = each.value.node_id
  name           = each.value.name
  description    = each.value.description
  enabled        = each.value.enabled
  ipv4_addresses = each.value.ipv4_addresses
  ipv6_addresses = each.value.ipv6_addresses
  vlan_id        = each.value.vlan_id
  vrf_id         = each.value.vrf_id
  labels         = each.value.labels
  annotations    = each.value.annotations
}

locals {
  fabric_vnis = flatten([
    for fabric in try(local.hyperfabric.fabrics, []) : [
      for vni in try(fabric.vnis, []) : {
        key         = format("%s/%s", fabric.name, vni.name)
        fabric_id   = hyperfabric_fabric.fabric[fabric.name].id
        name        = vni.name
        description = try(vni.description, local.defaults.hyperfabric.fabrics.vnis.description, null)
        vni         = try(vni.vni, local.defaults.hyperfabric.fabrics.vnis.vni, null)
        vrf_id      = try(hyperfabric_vrf.vrf[vni.vrf].vrf_id, null)
        svi = {
          ipv4_addresses = try(vni.svi.ipv4_addresses, local.defaults.hyperfabric.fabrics.vnis.svi.ipv4_addresses, null)
          ipv6_addresses = try(vni.svi.ipv6_addresses, local.defaults.hyperfabric.fabrics.vnis.svi.ipv6_addresses, null)
          enabled        = try(vni.svi.enabled, local.defaults.hyperfabric.fabrics.vnis.svi.enabled, null)
        }
        members = flatten(concat(
          [
            for member in try(vni.members, []) : [
              for node in try(member.nodes, []) : [
                for port in try(member.ports, []) : {
                  node_id   = hyperfabric_node.node[format("%s/%s", fabric.name, node)].node_id
                  port_name = port
                  vlan_id   = try(member.vlan_id, null)
                }
              ]
            ] if try(member.nodes, null) != null && try(member.ports, null) != null
          ],
          [
            for member in try(vni.members, []) : [
              for node in try(member.nodes, []) : {
                node_id   = hyperfabric_node.node[format("%s/%s", fabric.name, node)].id
                port_name = try(member.port, "*")
                vlan_id   = try(member.vlan_id, null)
              }
            ] if try(member.nodes, null) != null && try(member.ports, null) == null
          ],
          [
            for member in try(vni.members, []) : [
              for port in try(member.ports, []) : {
                node_id   = try(hyperfabric_node.node[format("%s/%s", fabric.name, member.node)].node_id, "*")
                port_name = port
                vlan_id   = try(member.vlan_id, null)
              }
            ] if try(member.nodes, null) == null && try(member.ports, null) != null
          ],
          [
            for member in try(vni.members, []) : {
              node_id   = try(hyperfabric_node.node[format("%s/%s", fabric.name, member.node)].node_id, "*")
              port_name = try(member.port, "*")
              vlan_id   = try(member.vlan_id, null)
            } if try(member.nodes, null) == null && try(member.ports, null) == null
          ]
        ))
        labels = try(vni.labels, local.defaults.hyperfabric.fabrics.vnis.labels, null)
        annotations = [for key, value in try(vni.annotations, {}) : {
          name  = key
          value = value
        }]
      }
    ]
  ])
}

resource "hyperfabric_vni" "vni" {
  for_each = { for vni in local.fabric_vnis : vni.key => vni }

  fabric_id   = each.value.fabric_id
  name        = each.value.name
  description = each.value.description
  vni         = each.value.vni
  vrf_id      = each.value.vrf_id
  svi         = each.value.svi
  members     = each.value.members
  labels      = each.value.labels
  annotations = each.value.annotations
}