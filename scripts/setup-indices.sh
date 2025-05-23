#!/bin/bash

echo "📊 Setting up Elasticsearch indices..."

# Wait for Elasticsearch to be ready
until curl -f http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=60s; do
    echo "Waiting for Elasticsearch..."
    sleep 10
done

# Create documents index
curl -X PUT "localhost:9200/documents" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "index.refresh_interval": "5s"
  },
  "mappings": {
    "properties": {
      "filename": {"type": "keyword"},
      "document_type": {"type": "keyword"},
      "processing_timestamp": {"type": "date"},
      "extracted_text": {
        "type": "text",
        "analyzer": "standard",
        "fields": {
          "keyword": {"type": "keyword", "ignore_above": 256}
        }
      },
      "analysis_results": {"type": "object"},
      "file_size": {"type": "long"},
      "content_type": {"type": "keyword"}
    }
  }
}'

# Create alerts index
curl -X PUT "localhost:9200/compliance-alerts" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "alert_type": {"type": "keyword"},
      "document": {"type": "keyword"},
      "timestamp": {"type": "date"},
      "severity": {"type": "keyword"},
      "message": {"type": "text"},
      "analysis": {"type": "object"},
      "resolved": {"type": "boolean", "value": false}
    }
  }
}'

# Create index patterns in Kibana
echo "⏳ Waiting for Kibana..."
until curl -f http://localhost:5601/api/status; do
    sleep 10
done

# Import Kibana index patterns
curl -X POST "localhost:5601/api/saved_objects/index-pattern" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -d '{
    "attributes": {
      "title": "compliance-alerts*",
      "timeFieldName": "timestamp"
    }
  }'

echo "✅ Elasticsearch indices and Kibana patterns created successfully!"