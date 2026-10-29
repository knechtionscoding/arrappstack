# rclone (seedbox pull)

`rclone.conf` defines the `seedbox` SFTP remote used by the `rclone-seedbox-pull`
container. It is committed **without the password**. The password is supplied at
runtime through an environment variable, which rclone uses to fill in (or
override) the remote's `pass` field:

```
.env (not committed)                 docker-compose.yml                      rclone
RCLONE_SEEDBOX_OBSCURED_PASS=...  →  RCLONE_CONFIG_SEEDBOX_PASS=${...}   →  [seedbox] pass
```

The value must be the **obscured** form of the password (`rclone obscure`), not
the plain text. Obscuring is reversible, so treat the obscured value exactly like
the password itself: it belongs only in `arrappstack/.env` on the host.

## Setting or rotating the password

1. Change the password with the seedbox provider.
2. Obscure the new password on the NAS. This reads it from the terminal without
   echoing it and without leaving it in your shell history:

   ```sh
   read -rs PW && printf '%s' "$PW" | docker run --rm -i rclone/rclone obscure - ; unset PW
   ```

3. Put the output in `arrappstack/.env`:

   ```sh
   RCLONE_SEEDBOX_OBSCURED_PASS=<output from step 2>
   ```

4. Recreate the container so it picks up the new value:

   ```sh
   docker compose up -d rclone-seedbox-pull
   ```

5. Check that it can log in:

   ```sh
   docker exec rclone-seedbox-pull rclone lsd seedbox:
   ```

## Recreating the config from scratch

If `rclone.conf` is ever lost, this regenerates it (still without the password):

```sh
cat > rclone.conf <<'EOF'
[seedbox]
type = sftp
host = ftl11.seedit4.me
user = seedit4me
port = 2113
md5sum_command = none
sha1sum_command = none
shell_type = none
disable_hashcheck = true
known_hosts_file = /config/known_hosts
EOF
```

If the seedbox's host key changes, refresh `known_hosts` and check the
fingerprint against the one your provider publishes:

```sh
ssh-keyscan -p 2113 ftl11.seedit4.me > known_hosts
```
