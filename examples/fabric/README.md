<!-- BEGIN_TF_DOCS -->
# Hyperfabric Example

Set environment variables pointing to Hyperfabric:

```bash
export HYPERFABRIC_TOKEN=abc123
```

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

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
<!-- END_TF_DOCS -->