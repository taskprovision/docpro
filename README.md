# Document Processing Center 📄

An advanced document processing system with AI, OCR, and real-time compliance analysis.

## 🚀 Features

- **🤖 AI Document Analysis**: Automatic analysis of COR, invoices, and contracts
- **🔍 OCR Processing**: Text recognition from images and scans
- **⚖️ Compliance Monitoring**: Detection of compliance violations
- **📊 Real-time Analytics**: Kibana dashboards with processing metrics
- **🚨 Smart Alerts**: Notifications for high-risk documents
- **🗄️ Document Storage**: Secure storage with MinIO
- **🔄 Automated Workflows**: Document processing pipelines

## 🛠️ Project Structure

- `config/`: Configuration files for services
- `scripts/`: Utility scripts for setup and maintenance
- `templates/`: Document processing templates
- `sample-docs/`: Sample documents for testing

## 🚀 Funkcje

- **🤖 AI Document Analysis**: Automatyczna analiza dokumentów COR, faktur i umów
- **🔍 OCR Processing**: Rozpoznawanie tekstu z obrazów i skanów
- **⚖️ Compliance Monitoring**: Wykrywanie naruszeń i problemów zgodności
- **📊 Real-time Analytics**: Dashboardy w Kibana z metrykami przetwarzania
- **🚨 Smart Alerts**: Powiadomienia o dokumentach wysokiego ryzyka
- **🗄️ Document Storage**: Bezpieczne przechowywanie w MinIO
- **🔄 Automated Workflows**: Apache Camel processing pipelines
- 
**Kluczowe możliwości:**
- 🤖 **Inteligentna analiza dokumentów** - COR, faktury, umowy
- 📊 **Real-time monitoring** w Kibana
- 🚨 **Smart alerts** dla compliance i ryzyka  
- 🔄 **Automated workflows** z Apache Camel
- 🗄️ **Scalable storage** z MinIO

Czy przejść do **trzeciego projektu - Recruitment Automation Suite**? 👥rf: true" \
  -d '{
    "attributes": {
      "title": "documents*",
      "timeFieldName": "processing_timestamp"
    }
  }'


## 📋 System Requirements

- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: 20GB free space
- **CPU**: 4+ cores (recommended for AI processing)
- **Docker & Docker Compose**: Latest versions

## ⚡ Quick Start

1. Clone the repository and set up environment:
   ```bash
   git clone <repository>
   cd docpro
   cp .env.example .env
   ```

2. Edit the configuration in `.env` as needed

3. Install and start the services:
   ```bash
   make install    # Install dependencies
   make dev        # Start all services
   make setup      # Set up Elasticsearch indices
   make samples    # Upload sample documents
   ```

4. Access the services:
   - MinIO Console: http://localhost:9001 (minioadmin/minioadmin)
   - Elasticsearch: http://localhost:9200
   - Kibana: http://localhost:5601

## 🎯 Available Services

| Service | URL | Credentials | Description |
|---------|-----|-------------|-------------|
| **MinIO Console** | http://localhost:9001 | minioadmin/minioadmin | Object Storage |
| **Elasticsearch** | http://localhost:9200 | - | Search Engine |
| **Kibana** | http://localhost:5601 | - | Analytics & Dashboards |
| **Apache Tika** | http://localhost:9998 | - | Document Parser |

## 📁 Supported Document Types

### 1. **Certificates of Conformity (COR)**
- ✅ Automatic certificate validation
- 🔍 Standards compliance checking
- ⏰ Expiration date monitoring
- 🚨 Compliance issue alerts

### 2. **Invoices**  
- 💰 Financial data extraction
- 📊 High-value invoice detection
- ✔️ Data validation
- 🔄 Automated approval workflows

### 3. **Contracts**
- ⚖️ Legal risk analysis
- 📋 Key clause identification
- 🚩 Risk factor detection
- 📈 Contract risk scoring

## 🔧 Konfiguracja AI

Edytuj `.env` aby dostosować modele AI:

```bash
# Model Configuration
LLM_MODEL=llama2:13b          # Model for document analysis
LLM_TEMPERATURE=0.1           # Lower = more consistent results
CONFIDENCE_THRESHOLD=0.8      # Minimum confidence for auto-processing
```

## 📊 Monitoring & Analytics

### Kibana Dashboards
- **Document Processing Overview**: Wolumen, typy, czasy przetwarzania
- **Compliance Alerts**: Wykryte problemy i ich status
- **Performance Metrics**: Wydajność systemu i bottlenecki
- **Risk Assessment**: Analiza ryzyka dla umów i certyfikatów

### Key Metrics
- Documents processed per hour
- Average processing time
- Compliance success rate
- Alert resolution time
- Storage utilization

## 🚨 System Alertów

### Typy Alertów
- **🔴 HIGH**: Problemy compliance, wysokie ryzyko
- **🟡 MEDIUM**: Faktury wymagające zatwierdzenia
- **🟢 LOW**: Problemy formatowania, missing translations

### Kanały Powiadomień
- Slack webhooks
- Email notifications  
- Kibana alerts
- Dashboard notifications

## 🔄 Processing Pipeline

```
Document Upload → File Detection → Type Classification
        ↓
Text Extraction (Tika/OCR) → AI Analysis (Ollama)
        ↓
Risk Assessment → Compliance Check → Alert Generation
        ↓
Storage (MinIO) → Indexing (Elasticsearch) → Dashboard Update
```

## 🛠️ Administration

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make install` | Install project dependencies |
| `make dev` | Start all services |
| `make stop` | Stop all services |
| `make restart` | Restart all services |
| `make status` | Show service status |
| `make logs` | View service logs |
| `make clean` | Remove all containers and volumes |
| `make setup` | Set up Elasticsearch indices |
| `make samples` | Upload sample documents |
| `make backup` | Create a backup |
| `make restore` | Restore from backup |

### Manual Commands

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f [service-name]

# Create backup
./scripts/backup.sh
```

### Troubleshooting

**Elasticsearch Issues:**
```bash
# Reset Elasticsearch data
docker-compose down
sudo rm -rf data/elasticsearch/*
docker-compose up -d elasticsearch
```

**MinIO Access Issues:**
```bash
# Reset MinIO credentials
docker-compose exec minio mc admin user add minio newuser newpassword
```

**AI Model Issues:**
```bash
# Reload AI models
docker-compose exec ollama ollama pull llama2:13b
```

## 📈 Performance Tuning

### For High Volume Processing
```yaml
# In docker-compose.yml, increase resources:
elasticsearch:
  environment:
    - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    
ollama:
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
```

### Storage Optimization
- Implement document archival policies
- Use compression for older documents
- Regular index optimization

## 🔐 Security

- All internal communication encrypted
- Document access logging
- Role-based access control in Kibana
- Secure storage in MinIO with policies

## 📞 Support

**Logs Location:**
- Application: `docker-compose logs`
- Elasticsearch: `data/elasticsearch/logs/`
- Processing: Check Kibana logs dashboard

**Common Issues:**
1. **Out of Memory**: Increase Docker memory limits
2. **Slow Processing**: Check AI model size and GPU availability  
3. **Missing Documents**: Verify MinIO bucket permissions
4. **No Alerts**: Check Elasticsearch connectivity

---

🎉 **Ready to process thousands of documents with AI-powered intelligence!**
```



**Kluczowe zmiany:**
✅ **Poprawione obrazy Docker** - wszystkie wersje istnieją
✅ **Node-RED zamiast Camel** - prostsze w konfiguracji  
✅ **Working OCR service** - hertzg/tesseract-server
✅ **Uproszczona architektura** - mniej złożona, ale funkcjonalna



























