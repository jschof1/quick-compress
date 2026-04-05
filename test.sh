#!/bin/bash

# Quick Compress - Test Suite
# Run this to verify the installation works correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="/tmp/quick-compress-test"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Quick Compress Test Suite"
echo "=========================="
echo ""

# Setup
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Test 1: Check if ImageMagick is installed
echo -n "Test 1: ImageMagick installed... "
if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC} - ImageMagick not found"
    exit 1
fi

# Test 2: Create a test image
echo -n "Test 2: Create test image... "
if command -v magick >/dev/null 2>&1; then
    magick -size 100x100 xc:blue test.jpg
else
    convert -size 100x100 xc:blue test.jpg
fi
echo -e "${GREEN}PASS${NC}"

# Test 3: Run compression
echo -n "Test 3: Compress single image... "
"$SCRIPT_DIR/compress" test.jpg > /dev/null 2>&1
if [ -f "test.webp" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC} - WebP file not created"
    exit 1
fi

# Test 4: Verify output format
echo -n "Test 4: Verify WebP format... "
if file test.webp | grep -q "Web/P"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC} - Not a valid WebP file"
    exit 1
fi

# Test 5: Test folder processing
echo -n "Test 5: Process folder... "
mkdir -p subfolder
if command -v magick >/dev/null 2>&1; then
    magick -size 50x50 xc:red subfolder/test2.png
else
    convert -size 50x50 xc:red subfolder/test2.png
fi
"$SCRIPT_DIR/compress" subfolder > /dev/null 2>&1
if [ -f "subfolder/test2.webp" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC} - Folder processing failed"
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo ""
echo "=========================="
echo -e "${GREEN}All tests passed!${NC}"
echo ""
