#!/bin/bash

echo "📤 Uploading sample documents to MinIO..."

# Wait for MinIO to be ready
until curl -f http://localhost:9000/minio/health/live; do
    echo "Waiting for MinIO..."
    sleep 5
done

# Install MinIO client if not present
if ! command -v mc &> /dev/null; then
    echo "📥 Installing MinIO client..."
    wget -q https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x mc
    sudo mv mc /usr/local/bin/ 2>/dev/null || mv mc ~/.local/bin/ 2>/dev/null || PATH=".:$PATH"
fi

# Configure MinIO client
mc alias set local http://localhost:9000 minioadmin minioadmin123

# Create buckets
mc mb local/documents local/processed local/templates --ignore-existing

echo "✅ MinIO storage ready for document processing!"