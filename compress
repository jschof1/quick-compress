#!/bin/bash

# Image optimization script using ImageMagick
# Converts to WebP, caps at 1280px, targets output under 200KB
# Usage: compress <file|folder>

INPUT="${1:-.}"
MAX_WIDTH=1280
MAX_HEIGHT=1280
MAX_SIZE=204800   # 200KB
QUALITY=80
MIN_QUALITY=25

# Check for ImageMagick command (v7 uses 'magick', older uses 'convert')
if command -v magick &> /dev/null; then
    IMG_CMD="magick"
    ID_CMD="magick identify"
elif command -v convert &> /dev/null; then
    IMG_CMD="convert"
    ID_CMD="identify"
else
    echo "Error: ImageMagick not found. Install with: brew install imagemagick"
    exit 1
fi

if [ ! -e "$INPUT" ]; then
    echo "Error: '$INPUT' does not exist"
    echo "Usage: compress <file|folder>"
    exit 1
fi

get_size() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null
}

convert_at() {
    local input="$1"
    local resize_w="$2"
    local resize_h="$3"
    local quality="$4"
    local output="$5"

    if [ "$resize_w" != "0" ]; then
        $IMG_CMD "$input" -resize "${resize_w}x${resize_h}>" -quality "$quality" "$output"
    else
        $IMG_CMD "$input" -quality "$quality" "$output"
    fi
}

optimize_image() {
    local input="$1"
    local output="${input%.*}.webp"
    local temp_output="${input%.*}_temp.webp"

    local orig_size
    orig_size=$(get_size "$input")
    local orig_kb=$((orig_size / 1024))

    echo -n "  $(basename "$input") (${orig_kb}KB) → "

    # Get original dimensions
    local width
    local height
    width=$($ID_CMD -format "%w" "$input" 2>/dev/null)
    height=$($ID_CMD -format "%h" "$input" 2>/dev/null)

    if [ -z "$width" ] || [ -z "$height" ]; then
        echo "SKIPPED (could not read dimensions)"
        return 1
    fi

    # Determine working dimensions: cap to MAX but no upscale
    local work_w=$MAX_WIDTH
    local work_h=$MAX_HEIGHT

    if [ "$width" -le "$work_w" ] && [ "$height" -le "$work_h" ]; then
        # Already small enough, no resize needed
        work_w=0
        work_h=0
    fi

    # --- Pass 1: Try initial quality with resize ---
    convert_at "$input" "$work_w" "$work_h" "$QUALITY" "$temp_output"
    local size
    size=$(get_size "$temp_output")

    if [ "$size" -le "$MAX_SIZE" ]; then
        mv "$temp_output" "$output"
        local final_kb=$((size / 1024))
        echo "${final_kb}KB (q${QUALITY})"
        return 0
    fi

    # --- Pass 2: Binary search quality from QUALITY down to MIN_QUALITY ---
    local low=$MIN_QUALITY
    local high=$QUALITY
    local best_q=0

    while [ "$low" -le "$high" ]; do
        local mid=$(((low + high) / 2))
        convert_at "$input" "$work_w" "$work_h" "$mid" "$temp_output"
        size=$(get_size "$temp_output")

        if [ "$size" -le "$MAX_SIZE" ]; then
            best_q=$mid
            low=$((mid + 1))
        else
            high=$((mid - 1))
        fi
    done

    if [ "$best_q" -gt 0 ]; then
        convert_at "$input" "$work_w" "$work_h" "$best_q" "$temp_output"
        mv "$temp_output" "$output"
        local final_kb=$(($(get_size "$output") / 1024))
        echo "${final_kb}KB (q${best_q})"
        return 0
    fi

    # --- Pass 3: Progressive downsize ---
    # Quality alone couldn't do it. Shrink dimensions in steps and retry.
    local scale_steps="0.75 0.6 0.5 0.4 0.33"

    if [ "$work_w" = "0" ]; then
        # Image was already within max dims, so start from actual size
        work_w=$width
        work_h=$height
    fi

    for scale in $scale_steps; do
        local scale_pct
        local new_w
        local new_h
        scale_pct=${scale#0.}
        new_w=$((work_w * scale_pct / 100))
        new_h=$((work_h * scale_pct / 100))

        # Don't go below 320px wide
        if [ "$new_w" -lt 320 ]; then
            break
        fi

        # Try at initial quality first
        convert_at "$input" "$new_w" "$new_h" "$QUALITY" "$temp_output"
        size=$(get_size "$temp_output")

        if [ "$size" -le "$MAX_SIZE" ]; then
            mv "$temp_output" "$output"
            local final_kb=$((size / 1024))
            echo "${final_kb}KB (${new_w}x${new_h}, q${QUALITY})"
            return 0
        fi

        # Binary search quality at this smaller size
        low=$MIN_QUALITY
        high=$QUALITY
        best_q=0

        while [ "$low" -le "$high" ]; do
            local mid=$(((low + high) / 2))
            convert_at "$input" "$new_w" "$new_h" "$mid" "$temp_output"
            size=$(get_size "$temp_output")

            if [ "$size" -le "$MAX_SIZE" ]; then
                best_q=$mid
                low=$((mid + 1))
            else
                high=$((mid - 1))
            fi
        done

        if [ "$best_q" -gt 0 ]; then
            convert_at "$input" "$new_w" "$new_h" "$best_q" "$temp_output"
            mv "$temp_output" "$output"
            local final_kb=$(($(get_size "$output") / 1024))
            echo "${final_kb}KB (${new_w}x${new_h}, q${best_q})"
            return 0
        fi
    done

    # If we get here, something went very wrong
    rm -f "$temp_output"
    echo "FAILED (could not get under 200KB)"
    return 1
}

# --- Main ---

if [ -f "$INPUT" ]; then
    optimize_image "$INPUT"
else
    extensions="jpg jpeg png gif bmp tiff webp"

    echo "compress -> $INPUT (max ${MAX_WIDTH}px, <200KB)"
    echo "---------------------------------------------------"

    local_count=0
    for ext in $extensions; do
        ext_upper=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
        for img in "$INPUT"/*."$ext" "$INPUT"/*."$ext_upper"; do
            [ -f "$img" ] || continue
            local_count=$((local_count + 1))
            optimize_image "$img"
        done
    done

    echo "---------------------------------------------------"
    echo "Done. ${local_count} images processed."
fi
