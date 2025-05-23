#!/bin/bash
set -e

echo "📄 Installing Document Processing Center..."

# Check requirements
command -v docker >/dev/null 2>&1 || { echo "Docker required but not installed. Aborting." >&2; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose required but not installed. Aborting." >&2; exit 1; }

# Check system resources
MEMORY=$(free -g | awk '/^Mem:/{print $2}')
if [ "$MEMORY" -lt 8 ]; then
    echo "⚠️  Warning: Less than 8GB RAM detected. Performance may be affected."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
fi

# Create directories
mkdir -p {config/{tika,elasticsearch,kibana,camel/routes,minio},data/{elasticsearch,minio,tika,processed},scripts,templates,sample-docs}

# Set permissions for Elasticsearch
chmod 777 data/elasticsearch

# Copy example env file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Please edit .env file with your configuration"
fi

echo "✅ Project structure created!"
echo "🚀 Starting services..."

# Start infrastructure first
docker-compose up -d elasticsearch minio

echo "⏳ Waiting for Elasticsearch and MinIO..."
sleep 45

# Start remaining services
docker-compose up -d

echo "⏳ Waiting for all services to start..."
sleep 60

# Setup Elasticsearch indices
echo "📊 Setting up Elasticsearch indices..."
./scripts/setup-indices.sh

# Setup MinIO buckets
echo "🗄️ Setting up MinIO storage..."
docker-compose exec -T minio mc alias set minio http://localhost:9000 minioadmin minioadmin123
docker-compose exec -T minio mc mb minio/documents minio/processed minio/templates --ignore-existing

# Setup sample documents
echo "📋 Uploading sample documents..."
./scripts/upload-samples.sh

# Setup Ollama models
echo "🤖 Setting up AI models..."
docker-compose exec -T ollama ollama pull llama2:13b
docker-compose exec -T ollama ollama pull mistral:7b

echo "✅ Document Processing Center is ready!"
echo ""
echo "🎉 Access your services:"
echo "   • Kibana Dashboard: http://localhost:5601"
echo "   • MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
echo "   • Tika Server: http://localhost:9998"
echo "   • Elasticsearch: http://localhost:9200"
echo ""
echo "🧪 Test document processing: ./scripts/test-documents.sh"