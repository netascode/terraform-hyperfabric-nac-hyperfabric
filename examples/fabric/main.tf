module "hyperfabric" {
  source  = "netascode/nac-hyperfabric/hyperfabric"
  version = ">= 0.1.0"

  yaml_files = ["fabric.yaml"]
}
