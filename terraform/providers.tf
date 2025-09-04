terraform {
  required_version = ">= 1.5"
  required_providers {
    sonarr   = { source = "devopsarr/sonarr",   version = "~> 3.4" }
    radarr   = { source = "devopsarr/radarr",   version = "~> 2.3" }
    whisparr = { source = "devopsarr/whisparr", version = "~> 1.2" }
    prowlarr = { source = "devopsarr/prowlarr", version = "~> 1.2" }
  }
}

# Your *Arr endpoints (these run behind gluetun in your stack)
provider "sonarr"   { url = var.sonarr_url,   api_key = var.sonarr_api_key }
provider "radarr"   { url = var.radarr_url,   api_key = var.radarr_api_key }
provider "whisparr" { url = var.whisparr_url, api_key = var.whisparr_api_key }
# Optional if you also want to manage Prowlarr (indexers/apps)
provider "prowlarr" { url = var.prowlarr_url, api_key = var.prowlarr_api_key }
