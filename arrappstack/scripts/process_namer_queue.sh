#!/bin/sh
#
# process_namer_queue.sh (POSIX/BusyBox compatible)
#
# Processes every file sitting in namer's watch folder, one at a time,
# by calling `namer rename -f <single file>` directly inside the
# namer container. This bypasses the watchdog/inotify entirely, since
# inotify events don't propagate reliably through this NAS's bind mounts.
#
# Run this on a schedule (cron) rather than relying on the watchdog
# to detect new files automatically.
#
# Files are processed ONE AT A TIME and each is a single file (never a
# directory), which avoids namer's "treat folder as one release" behavior
# that caused a file loss earlier.

WATCH_DIR_HOST="/volume1/data/media/adult/_namer/watch"
WATCH_DIR_CONTAINER="/data/_namer/watch"
CONTAINER_NAME="namer"
LOG_FILE="/volume1/data/media/adult/_namer/process_log.txt"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "===== Run started: $TIMESTAMP =====" >> "$LOG_FILE"

if [ ! -d "$WATCH_DIR_HOST" ]; then
    echo "$TIMESTAMP | ERROR | Watch dir not found: $WATCH_DIR_HOST" >> "$LOG_FILE"
    exit 1
fi

# Check the container is actually up before doing anything
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "$TIMESTAMP | ERROR | Container '$CONTAINER_NAME' is not running. Skipping this run." >> "$LOG_FILE"
    exit 1
fi

find "$WATCH_DIR_HOST" -maxdepth 1 -type f -print0 | \
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    container_path="${WATCH_DIR_CONTAINER}/${filename}"

    ts=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$ts | INFO | Processing: $filename" >> "$LOG_FILE"

    # Run namer against this single file only (never the whole directory)
    docker exec "$CONTAINER_NAME" namer rename -f "$container_path" >> "$LOG_FILE" 2>&1
    result=$?

    ts=$(date "+%Y-%m-%d %H:%M:%S")
    if [ "$result" -eq 0 ]; then
        echo "$ts | SUCCESS | Finished: $filename" >> "$LOG_FILE"
    else
        echo "$ts | FAILED (exit $result) | $filename" >> "$LOG_FILE"
    fi

    # Small pause between files to avoid hammering the TPDB API
    sleep 5
done

ts=$(date "+%Y-%m-%d %H:%M:%S")
echo "$ts | INFO | Run complete." >> "$LOG_FILE"
echo "===== Run finished: $ts =====" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
