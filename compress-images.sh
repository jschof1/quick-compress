#!/bin/bash

# Image optimization script using ImageMagick
# Converts to WebP, limits dimensions, keeps under 500KB, maintains quality
# Usage: compress <file|folder>

INPUT="${1:-.}"
MAX_WIDTH=1920
MAX_HEIGHT=1080
MAX_SIZE=512000  # 500KB in bytes
QUALITY=85

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

optimize_image() {
    local input="$1"
    local output="${input%.*}.webp"
    local temp_output="${input%.*}_temp.webp"
    
    echo "Processing: $(basename "$input")"
    
    # Get original dimensions
    local width=$($ID_CMD -format "%w" "$input" 2>/dev/null)
    local height=$($ID_CMD -format "%h" "$input" 2>/dev/null)
    
    # Determine resize parameters
    local resize=""
    if [ "$width" -gt "$MAX_WIDTH" ] || [ "$height" -gt "$MAX_HEIGHT" ]; then
        resize="-resize ${MAX_WIDTH}x${MAX_HEIGHT}>"
    fi
    
    # Convert to WebP with quality
    $IMG_CMD "$input" $resize -quality $QUALITY "$temp_output"
    
    # Check file size and adjust quality if needed
    local size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)
    
    if [ "$size" -gt "$MAX_SIZE" ]; then
        # Binary search for best quality under 500KB
        local low=60
        local high=$QUALITY
        local best_quality=$low
        
        while [ $low -le $high ]; do
            local mid=$(((low + high) / 2))
            $IMG_CMD "$input" $resize -quality $mid "$temp_output"
            size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)
            
            if [ "$size" -le "$MAX_SIZE" ]; then
                best_quality=$mid
                low=$((mid + 1))
            else
                high=$((mid - 1))
            fi
        done
        
        # Final conversion with best quality found
        if [ "$best_quality" -ne $QUALITY ]; then
            $IMG_CMD "$input" $resize -quality $best_quality "$temp_output"
            echo "  → Reduced quality to ${best_quality}% to meet size limit"
        fi
    fi
    
    # Replace original with optimized version
    mv "$temp_output" "$output"
    
    # Get final stats
    local final_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)
    local final_size_kb=$((final_size / 1024))
    
    echo "  ✓ Saved as: $(basename "$output") (${final_size_kb}KB)"
}

# Check if input is a file
if [ -f "$INPUT" ]; then
    # Process single file
    optimize_image "$INPUT"
    echo "Done! Image optimized."
else
    # Process directory
    # Supported image extensions
    extensions="jpg jpeg png gif bmp tiff"
    
    echo "Optimizing images in: $INPUT"
    echo "----------------------------------------"
    
    for ext in $extensions; do
        ext_upper=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
        for img in "$INPUT"/*.$ext "$INPUT"/*.$ext_upper; do
            [ -f "$img" ] && optimize_image "$img"
        done
    done
    
    echo "----------------------------------------"
    echo "Done! All images optimized."
fi
