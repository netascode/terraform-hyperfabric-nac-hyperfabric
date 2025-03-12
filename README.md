<!-- BEGIN_TF_DOCS -->
# Terraform Network-as-Code Cisco Hyperfabric Module

A Terraform module to configure Cisco Hyperfabric.

## Usage

This module supports an inventory driven approach, where a complete Hyperfabric configuration or parts of it are either modeled in one or more YAML files or natively using Terraform variables.

## Examples

Configuring a Fabric using YAML:

#### `fabric.yaml`

```yaml
---
hyperfabric:
  fabrics:
    - name: My Fabric 01
      description: My first HyperFabric
      address: 170 West Tasman Dr.
      city: San Jose
      country: USA
      location: sj01-1-101-AAA01
```

#### `main.tf`

```hcl
module "hyperfabric" {
  source  = "netascode/nac-hyperfabric/hyperfabric"
  version = ">= 0.1.0"

  yaml_files = ["fabric.yaml"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_hyperfabric"></a> [hyperfabric](#requirement\_hyperfabric) | >= 0.1.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.2.5 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_write_default_values_file"></a> [write\_default\_values\_file](#input\_write\_default\_values\_file) | Write all default values to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_yaml_directories"></a> [yaml\_directories](#input\_yaml\_directories) | List of paths to YAML directories. | `list(string)` | `[]` | no |
| <a name="input_yaml_files"></a> [yaml\_files](#input\_yaml\_files) | List of paths to YAML files. | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_values"></a> [default\_values](#output\_default\_values) | All default values. |
| <a name="output_model"></a> [model](#output\_model) | Full model. |
## Resources

| Name | Type |
|------|------|
| [hyperfabric_connection.connection](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/connection) | resource |
| [hyperfabric_fabric.fabric](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/fabric) | resource |
| [hyperfabric_node.node](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/node) | resource |
| [hyperfabric_node_loopback.node_loopback](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/node_loopback) | resource |
| [hyperfabric_node_management_port.node_management_port](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/node_management_port) | resource |
| [hyperfabric_node_port.node_port](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/node_port) | resource |
| [hyperfabric_node_sub_interface.node_sub_interface](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/node_sub_interface) | resource |
| [hyperfabric_user.user](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/user) | resource |
| [hyperfabric_vni.vni](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/vni) | resource |
| [hyperfabric_vrf.vrf](https://registry.terraform.io/providers/CiscoDevNet/hyperfabric/latest/docs/resources/vrf) | resource |
| [local_sensitive_file.defaults](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [terraform_data.validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
## Modules

No modules.
<!-- END_TF_DOCS -->