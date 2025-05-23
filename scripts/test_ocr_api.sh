#!/bin/bash
# Simple step-by-step test for OCR API
# Usage: ./scripts/test_ocr_api.sh /path/to/file.pdf

set -e

PDF_FILE="$1"
API_URL="http://localhost:8081/ocr"

if [ -z "$PDF_FILE" ]; then
  echo "Usage: $0 /path/to/file.pdf"
  exit 1
fi

if [ ! -f "$PDF_FILE" ]; then
  echo "File not found: $PDF_FILE"
  exit 2
fi

echo "Step 1: Uploading PDF to OCR API..."
RESPONSE=$(curl -s -X POST -F "file=@$PDF_FILE" "$API_URL")

if echo "$RESPONSE" | grep -q '"text"'; then
  echo "Step 2: OCR text received:"
  echo "--------------------------"
  echo "$RESPONSE" | jq -r .text
  echo "--------------------------"
else
  echo "Step 2: Error from OCR API:"
  echo "$RESPONSE"
fi
