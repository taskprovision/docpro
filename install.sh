#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}📄 Installing Document Processing System...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# Check docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}❌ docker-compose not found. Please install it.${NC}"
    exit 1
fi

# Setup .env file
if [ ! -f .env ]; then
    echo -e "${GREEN}🔧 Creating .env file from template...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}ℹ️  Please review and edit the .env file with your configuration${NC}"
    else
        echo -e "${YELLOW}⚠️  .env.example not found. Creating a basic .env file...${NC}"
        echo "# Document Processing Configuration" > .env
        echo "MINIO_ROOT_USER=minioadmin" >> .env
        echo "MINIO_ROOT_PASSWORD=minioadmin123" >> .env
        echo "MINIO_BUCKET=documents" >> .env
        echo "ELASTICSEARCH_HTTP_PORT=9200" >> .env
        echo "KIBANA_PORT=5601" >> .env
    fi
else
    echo -e "${GREEN}ℹ️  Using existing .env file${NC}"
fi

# Create required directories
echo -e "${GREEN}📂 Creating required directories...${NC}"
mkdir -p data/{elasticsearch,minio,node-red,ollama,input,processed}
mkdir -p scripts

# Set permissions
echo -e "${GREEN}🔒 Setting up permissions...${NC}"
chmod -R 777 data/elasticsearch
chmod -R 777 data/input
chmod +x scripts/*.sh 2>/dev/null || true

# Start services
echo -e "${GREEN}🚀 Starting services...${NC}"
docker-compose up -d --build

# Function to wait for a service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local name=$3
    local max_attempts=30
    local attempt=1

    echo -e "${YELLOW}⏳ Waiting for $name to be ready...${NC}"
    until nc -z $host $port; do
        if [ $attempt -ge $max_attempts ]; then
            echo -e "${YELLOW}❌ $name failed to start after $max_attempts attempts${NC}"
            docker-compose logs $name
            exit 1
        fi
        echo -e "${YELLOW}⏳ Waiting for $name ($attempt/$max_attempts)...${NC}"
        sleep 10
        attempt=$((attempt+1))
    done
    echo -e "${GREEN}✅ $name is ready${NC}" 
}

# Wait for critical services
wait_for_service localhost 9200 "Elasticsearch"
wait_for_service localhost 9001 "MinIO Console"
wait_for_service localhost 9998 "Apache Tika"

# Test Elasticsearch
echo -e "${GREEN}🔍 Testing Elasticsearch health...${NC}"
curl -f http://localhost:9200/_cluster/health?pretty

# Setup indices using the setup script
if [ -f "./scripts/setup-indices.sh" ]; then
    echo -e "${GREEN}📊 Setting up Elasticsearch indices...${NC}"
    chmod +x ./scripts/setup-indices.sh
    ./scripts/setup-indices.sh
else
    echo -e "${YELLOW}⚠️  setup-indices.sh not found, creating default index...${NC}"
    curl -X PUT "localhost:9200/documents" -H 'Content-Type: application/json' -d'
    {
      "mappings": {
        "properties": {
          "filename": {"type": "keyword"},
          "content": {"type": "text"},
          "timestamp": {"type": "date", "format": "strict_date_optional_time||epoch_millis"},
          "analysis": {"type": "object", "enabled": false},
          "metadata": {"type": "object"}
        }
      },
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
      }
    }'
fi

# Setup MinIO buckets
echo -e "${GREEN}🪣 Setting up MinIO buckets...${NC}"
if command -v mc &> /dev/null; then
    mc config host add local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD --api s3v4 2>/dev/null || true
    mc mb -p local/$MINIO_BUCKET 2>/dev/null || true
    mc mb -p local/processed 2>/dev/null || true
    echo -e "${GREEN}✅ MinIO buckets ready${NC}"
else
    echo -e "${YELLOW}⚠️  mc (MinIO Client) not found. Please create buckets manually in MinIO console${NC}"
fi

# Setup AI model if Ollama service exists
if docker-compose ps ollama &> /dev/null; then
    echo -e "${GREEN}🤖 Setting up AI model...${NC}"
    docker-compose exec -T ollama ollama pull llama2:7b || \
        echo -e "${YELLOW}⚠️  Failed to pull model. It will be downloaded on first use${NC}"
fi

# Create sample documents if directory is empty
if [ -z "$(ls -A data/input 2>/dev/null)" ]; then
    echo -e "${GREEN}📄 Creating sample documents...${NC}"
    mkdir -p data/input
    
    # Sample invoice
    cat > data/input/sample_invoice.txt << 'EOF'
SAMPLE INVOICE

Invoice Number: INV-2024-001
Date: 2024-01-20
Vendor: Acme Corp
Customer: Example Inc.
Amount: €5,000.00
Status: UNPAID

This is a test invoice for document processing.
EOF

    # Sample contract
    cat > data/input/sample_contract.txt << 'EOF'
SAMPLE CONTRACT

Contract ID: CNTR-2024-001
Parties: Acme Corp and Example Inc.
Effective Date: 2024-01-20
Expiry Date: 2025-01-19

This is a sample contract for demonstration purposes.
EOF

    # Sample report
    cat > data/input/sample_report.pdf.txt << 'EOF'
SAMPLE REPORT

Report ID: RPT-2024-001
Generated: 2024-01-20
Author: Document Processing System

This is a sample report in text format.
EOF
    
    echo -e "${GREEN}✅ Sample documents created in data/input/${NC}"
fi

# Final status
echo -e "\n${GREEN}✅ Installation complete!${NC}\n"

echo -e "${YELLOW}📋 Service Status:${NC}"
docker-compose ps

echo -e "\n${YELLOW}🌐 Access Services:${NC}"
echo -e "- MinIO Console: http://localhost:9001 (${MINIO_ROOT_USER:-minioadmin}/${MINIO_ROOT_PASSWORD:-minioadmin123})"
echo -e "- Kibana:        http://localhost:5601"
echo -e "- Elasticsearch: http://localhost:9200"
echo -e "- Node-RED:      http://localhost:1880"
echo -e "- Tika:          http://localhost:9998"

echo -e "\n${YELLOW}🚀 Next steps:${NC}"
echo "1. Access the MinIO console and verify the buckets were created"
echo "2. Check Elasticsearch indices in Kibana"
echo "3. Upload documents to the 'input' directory for processing"
echo "4. Configure your document processing workflows in Node-RED"

echo -e "${YELLOW}🧪 Test Tika:${NC}"
echo "   curl -T data/input/sample_invoice.txt http://localhost:9998/tika"

echo -e "\n${GREEN}🎉 Document Processing System is ready!${NC}\n"