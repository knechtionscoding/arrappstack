#!/bin/sh
#
# queue_for_namer.sh (POSIX/BusyBox compatible)
#
# Copies every video file from your adult library studio folders into
# namer's watch folder, so its watchdog can process them one at a time.
# Originals are left untouched (copy, not move) until you've verified
# the renamed result in dest_dir.
#
# Usage:
#   ./queue_for_namer.sh                # queue everything
#   ./queue_for_namer.sh "Adult Time"   # queue just one studio folder

LIBRARY_ROOT="/volume1/data/media/adult"
WATCH_DIR="${LIBRARY_ROOT}/_namer/watch"
EXCLUDE_DIR="${LIBRARY_ROOT}/_namer"

STUDIO_FILTER="$1"

mkdir -p "$WATCH_DIR"

if [ -n "$STUDIO_FILTER" ]; then
    SEARCH_PATH="${LIBRARY_ROOT}/${STUDIO_FILTER}"
    if [ ! -d "$SEARCH_PATH" ]; then
        echo "Studio folder not found: $SEARCH_PATH"
        exit 1
    fi
else
    SEARCH_PATH="$LIBRARY_ROOT"
fi

echo "Scanning: $SEARCH_PATH"
echo "Excluding: $EXCLUDE_DIR"
echo

COUNT=0

# BusyBox find supports -print0; use that + a POSIX read loop with IFS=
find "$SEARCH_PATH" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" \) -print0 | \
while IFS= read -r -d '' file; do
    case "$file" in
        "$EXCLUDE_DIR"/*) continue ;;
    esac

    filename=$(basename "$file")
    dest="${WATCH_DIR}/${filename}"

    if [ -e "$dest" ]; then
        echo "Already queued, skipping: $filename"
        continue
    fi

    echo "Queuing: $filename"
    cp "$file" "$dest"
    COUNT=$((COUNT + 1))
done

echo
echo "Done. Check $WATCH_DIR and namer's dest_dir once processing finishes:"
echo "  $LIBRARY_ROOT/_namer/dest"
