#!/bin/bash

BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating Document Processing Center backup..."

# Backup configuration and data
cp -r config/ "$BACKUP_DIR/"
cp -r templates/ "$BACKUP_DIR/"
cp docker-compose.yml "$BACKUP_DIR/"
cp .env "$BACKUP_DIR/" 2>/dev/null || echo "No .env file found"

# Backup Elasticsearch data
echo "💾 Backing up Elasticsearch indices..."
curl -X POST "localhost:9200/_snapshot/backup/snapshot_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || echo "Elasticsearch backup failed"

# Backup MinIO data
echo "🗄️  Backing up MinIO data..."
cp -r data/minio/ "$BACKUP_DIR/" 2>/dev/null || echo "MinIO data not found"

# Create compressed archive
tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ Backup created: ${BACKUP_DIR}.tar.gz"
echo "📊 Backup size: $(du -h ${BACKUP_DIR}.tar.gz | cut -f1)"