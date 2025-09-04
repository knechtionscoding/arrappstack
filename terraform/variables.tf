variable "sonarr_url"        { type = string }  # e.g. http://127.0.0.1:8989
variable "radarr_url"        { type = string }  # e.g. http://127.0.0.1:7878
variable "whisparr_url"      { type = string }  # e.g. http://127.0.0.1:6969
variable "prowlarr_url"      { type = string }  # e.g. http://127.0.0.1:9696
variable "sonarr_api_key"    { type = string, sensitive = true }
variable "radarr_api_key"    { type = string, sensitive = true }
variable "whisparr_api_key"  { type = string, sensitive = true }
variable "prowlarr_api_key"  { type = string, sensitive = true }

# qBittorrent creds (the qB that sits next to the *Arrs in the gluetun netns)
variable "qb_host"           { type = string }  # usually 127.0.0.1
variable "qb_port"           { type = number }  # 8080
variable "qb_username"       { type = string }
variable "qb_password"       { type = string, sensitive = true }

# Categories
variable "cat_tv"            { type = string, default = "tv" }
variable "cat_movies"        { type = string, default = "movies" }
variable "cat_xxx"           { type = string, default = "xxx" }

# Paths (REMOTE = what qB reports; LOCAL = how *Arr sees the same files)
variable "remote_tv"         { type = string, default = "/downloads/complete/tv" }
variable "remote_movies"     { type = string, default = "/downloads/complete/movies" }
variable "remote_xxx"        { type = string, default = "/downloads/complete/xxx" }

variable "local_tv"          { type = string, default = "/data/torrents/complete/tv" }
variable "local_movies"      { type = string, default = "/data/torrents/complete/movies" }
variable "local_xxx"         { type = string, default = "/data/torrents/complete/xxx" }
