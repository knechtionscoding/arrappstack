resource "radarr_download_client_qbittorrent" "qb" {
  name     = "qbittorrent"
  enable   = true
  host     = var.qb_host
  port     = var.qb_port
  username = var.qb_username
  password = var.qb_password
  category = var.cat_movies
  use_ssl  = false
}

resource "radarr_remote_path_mapping" "qb_movies" {
  host        = var.qb_host
  remote_path = var.remote_movies
  local_path  = var.local_movies
}
