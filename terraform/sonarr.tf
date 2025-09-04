# qBittorrent as a Sonarr download client
resource "sonarr_download_client_qbittorrent" "qb" {
  name     = "qbittorrent"
  enable   = true
  host     = var.qb_host      # 127.0.0.1 when sharing gluetun's netns
  port     = var.qb_port      # 8080
  username = var.qb_username
  password = var.qb_password
  category = var.cat_tv
  use_ssl  = false
}

# Remote Path Mapping (Sonarr)
resource "sonarr_remote_path_mapping" "qb_tv" {
  host        = var.qb_host          # must match the Download Client host exactly
  remote_path = var.remote_tv        # what qB reports
  local_path  = var.local_tv         # where Sonarr can see those files
}
