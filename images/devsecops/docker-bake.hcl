# Builds all three layered variants with one shared cache:
#   cd images/devsecops && docker buildx bake --load
# Each variant is a Dockerfile target; gitops builds FROM core, ai FROM gitops.

variable "TAG" {
  default = "local"
}

# Release metadata, set by build-devsecops-images.yml (v* tags).
variable "VERSION" {
  default = "dev"
}

variable "REVISION" {
  default = ""
}

group "default" {
  targets = ["core", "gitops", "ai"]
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile"
  # The ai stage bakes the repo's OpenCode config and the four agents in.
  contexts = {
    opencode-src = "../../opencode"
    agents-src   = "../../.agents/agents"
  }
  labels = {
    "org.opencontainers.image.version"  = VERSION
    "org.opencontainers.image.revision" = REVISION
  }
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

target "polyglot" {
  inherits = ["_common"]
  target   = "polyglot"
  tags     = ["ufawkes-devsecops-ai:${TAG}-polyglot"]
}
