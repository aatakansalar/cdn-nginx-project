#!/bin/bash
# preload_cache.sh
$SECRET_KEY="c2VjcmV0X2tleV9leGFtcGxlX3YxMjM="



POPULAR_IMAGES=("cat.1.jpg" "cat.2.jpg" "cat.3.jpg" "cat.4.jpg" "cat.5.jpg" "cat.6.jpg" "cat.7.jpg" "cat.8.jpg" "cat.9.jpg" "cat.10.jpg")
WIDTHS=(400 600 800)
HEIGHTS=(400 600 800)
BASE_URL="http://frontend/images"
LOG_FILE="/app/preload_log.txt"

generate_hmac() {
    local data="$1"
    echo -n "$data" | openssl dgst -sha256 -hmac "$SECRET_KEY" -binary | base64 | tr '+/' '-_' | tr -d '='
}

echo "Starting preload process at $(date)" >> "$LOG_FILE"

# Preload popular images without resizing
for IMAGE in "${POPULAR_IMAGES[@]}"; do
    URL="$BASE_URL/$IMAGE"
    echo "Preloading $URL" >> "$LOG_FILE"
    RESPONSE_HEADERS=$(curl -s -D - -o /dev/null "$URL")
    echo "$RESPONSE_HEADERS" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
done

# Preload popular images with common dimensions
for IMAGE in "${POPULAR_IMAGES[@]}"; do
    for WIDTH in "${WIDTHS[@]}"; do
        for HEIGHT in "${HEIGHTS[@]}"; do
            DATA="/images/$IMAGE?width=$WIDTH&height=$HEIGHT"
            HMAC=$(generate_hmac "$DATA")
            URL="$BASE_URL/$IMAGE?width=$WIDTH&height=$HEIGHT&hmac=$HMAC"
            echo "Preloading $URL" >> "$LOG_FILE"
            RESPONSE_HEADERS=$(curl -s -D - -o /dev/null "$URL")
            echo "$RESPONSE_HEADERS" >> "$LOG_FILE"
            echo "" >> "$LOG_FILE"
        done
    done
done

echo "Preload process completed at $(date)" >> "$LOG_FILE"
