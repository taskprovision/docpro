#!/bin/bash
set -e

echo "📄 Installing Document Processing (Minimal Working Version)..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Create directories
mkdir -p data/{elasticsearch,minio,node-red,ollama,input,processed}
mkdir -p scripts

# Set permissions
chmod 777 data/elasticsearch
chmod 777 data/input

echo "🚀 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 45

# Test Elasticsearch
echo "🔍 Testing Elasticsearch..."
until curl -f http://localhost:9200/_cluster/health; do
    echo "Waiting for Elasticsearch..."
    sleep 10
done

# Setup basic index
echo "📊 Creating basic document index..."
curl -X PUT "localhost:9200/documents" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "properties": {
      "filename": {"type": "keyword"},
      "content": {"type": "text"},
      "timestamp": {"type": "date"},
      "analysis": {"type": "object"}
    }
  }
}'

# Test Ollama
echo "🤖 Setting up AI model..."
docker-compose exec -T ollama ollama pull llama2:7b || echo "AI model will be downloaded on first use"

# Create test document
echo "📄 Creating test document..."
cat > data/input/test-document.txt << 'EOF'
SAMPLE INVOICE

Invoice Number: INV-2024-001
Date: 2024-01-20
Amount: €5,000.00

This is a test invoice for document processing.
EOF

echo "✅ Installation complete!"
echo ""
echo "🎉 Services available at:"
echo "   • Node-RED:     http://localhost:1880"
echo "   • Kibana:       http://localhost:5601"
echo "   • MinIO:        http://localhost:9001 (minioadmin/minioadmin123)"
echo "   • Elasticsearch: http://localhost:9200"
echo "   • Tika:         http://localhost:9998"
echo ""
echo "📁 Drop documents in data/input/ folder"
echo "🔧 Configure workflows in Node-RED"
echo ""
echo "🧪 Test Tika:"
echo "   curl -T data/input/test-document.txt http://localhost:9998/tika"