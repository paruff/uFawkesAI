# Builds all three layered variants with one shared cache:
#   cd images/devsecops && docker buildx bake --load
# Each variant is a Dockerfile target; gitops builds FROM core, ai FROM gitops.

variable "TAG" {
  default = "local"
}

group "default" {
  targets = ["core", "gitops", "ai"]
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile"
}

target "core" {
  inherits = ["_common"]
  target   = "core"
  tags     = ["ufawkes-devsecops-core:${TAG}"]
}

target "gitops" {
  inherits = ["_common"]
  target   = "gitops"
  tags     = ["ufawkes-devsecops-gitops:${TAG}"]
}

target "ai" {
  inherits = ["_common"]
  target   = "ai"
  tags     = ["ufawkes-devsecops-ai:${TAG}"]
}
