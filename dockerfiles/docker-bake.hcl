variable "DISTRO" {
  default = "bookworm"
}

variable "GIT_COMMIT" {
  default = ""
}

variable "LATEST" {
  default = "true"
}

variable "CACHE" {
  default = false
}

variable VERSIONS {
  default = {
    DRBD = ["9.2.12", "9.1.23"]
    DRBD_REACTOR       = "1.6.0-1"
    K8S_AWAIT_ELECTION = "v0.4.1"
    KTLS_UTILS         = "0.11-1"
    LINSTOR            = "1.29.2-1"
  }
}

variable "REGISTRIES" {
  default = "quay.io/piraeusdatastore,docker.io/piraeusdatastore"
}

# Replace all characters that are not supported in a target name with "-".
function "escape" {
  params = [string]
  result = "${regex_replace(string, "[^a-zA-Z0-9_-]", "-")}"
}

# Generate tags based for all images
function "tags" {
  params = [name, version]
  result = flatten([
    for registry in split(",", REGISTRIES) :
    [
      // Full version
      "${registry}/${name}:v${version}",
      // Version shortened by the release
      "${registry}/${name}:v${regex("^[^-]+", version)}",
      // Full version + git commit, if set
        notequal("", GIT_COMMIT) ? "${registry}/${name}:v${version}-g${GIT_COMMIT}" : "",
      // Mark as latest, unless explicitly disabled
        equal("true", LATEST) ? "${registry}/${name}:latest" : "",
    ]
  ])
}

# Generate a cache-to configuration
function "cache-to" {
  params = [name]
  result = CACHE ? ["type=gha,scope=${name},mode=max"] : []
}


# Generate a cache-from configuration
function "cache-from" {
  params = [name]
  result = CACHE ? ["type=gha,scope=${name}"] : []
}

group "default" {
  targets = [
    "drbd-reactor",
    "drbd-driver-loader",
    "ktls-utils",
    "piraeus-server",
  ]
}

target "base" {
  dockerfile = "base.Dockerfile"
  inherits = ["common"]
  args = {
    DISTRO = DISTRO
  }
}

target "common" {
  platforms = ["linux/amd64", "linux/arm64"]
}

target "piraeus-server" {
  inherits = ["common"]
  tags = tags("piraeus-server", VERSIONS["LINSTOR"])
  cache-from = cache-from("piraeus-server")
  cache-to = cache-to("piraeus-server")
  context = "piraeus-server"
  contexts = { base = "target:base" }
  args = {
    LINSTOR_VERSION            = VERSIONS["LINSTOR"]
    K8S_AWAIT_ELECTION_VERSION = VERSIONS["K8S_AWAIT_ELECTION"]
  }
}

target "ktls-utils" {
  inherits = ["common"]
  tags = tags("ktls-utils", VERSIONS["KTLS_UTILS"])
  cache-from = cache-from("ktls-utils")
  cache-to = cache-to("ktls-utils")
  context = "ktls-utils"
  contexts = { base = "target:base" }
  args = {
    KTLS_UTILS_VERSION = VERSIONS["KTLS_UTILS"]
  }
}

target "drbd-reactor" {
  inherits = ["common"]
  tags = tags("drbd-reactor", VERSIONS["DRBD_REACTOR"])
  cache-from = cache-from("drbd-reactor")
  cache-to = cache-to("drbd-reactor")
  context = "drbd-reactor"
  contexts = { base = "target:base" }
  args = {
    DRBD_REACTOR_VERSION = VERSIONS["DRBD_REACTOR"]
  }
}

target "drbd-driver-loader" {
  name       = "drbd-driver-loader-${distro}-${escape(drbd_version)}"
  inherits = ["common"]
  tags = tags("drbd9-${distro}", drbd_version)
  cache-from = cache-from("drbd9-${distro}")
  cache-to = cache-to("drbd9-${distro}")
  context    = "drbd-driver-loader"
  dockerfile = "Dockerfile.${distro}"
  matrix = {
    drbd_version = VERSIONS["DRBD"]
    distro = [
      "centos7",
      "centos8",
      "almalinux8",
      "almalinux9",
      "bionic",
      "focal",
      "jammy",
      "noble",
      "bullseye",
      "buster",
      "bookworm",
    ]
  }
  args = {
    DRBD_VERSION = drbd_version
  }
}
