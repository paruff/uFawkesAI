# Builds the layered variants with one shared cache:
#   cd images/devsecops && docker buildx bake --load
# Each variant is a Dockerfile target; ai builds FROM core, polyglot FROM ai.

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
  targets = ["core", "ai"]
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
  tags     = ["fawkes-core:${TAG}"]
}

target "ai" {
  inherits = ["_common"]
  target   = "ai"
  tags     = ["fawkes-space-ai:${TAG}"]
}

target "polyglot" {
  inherits = ["_common"]
  target   = "polyglot"
  tags     = ["fawkes-space-ai:${TAG}-polyglot"]
}
