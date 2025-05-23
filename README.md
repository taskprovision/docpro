# Document Processing System

A comprehensive document processing system with AI-powered analysis, storage, and retrieval capabilities.

---

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/document-processing-system.git
   cd document-processing-system
   ```
2. **Copy and edit the environment file:**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```
3. **Start all services:**
   ```bash
   make dev
   ```

---

## 🖥️ Service URLs
- Node-RED: [http://localhost:1880](http://localhost:1880)
- OCR API: [http://localhost:8081](http://localhost:8081)
- MinIO Console: [http://localhost:9001](http://localhost:9001)
- Kibana: [http://localhost:5601](http://localhost:5601)
- Elasticsearch: [http://localhost:9200](http://localhost:9200)
- Tika Server: [http://localhost:9998](http://localhost:9998)
- (See `make help` for more)

---

## 📝 How OCR Automation Works in This System

### 1. Upload & Trigger
- Upload a PDF via Node-RED HTTP endpoint (`/start-ocr`) or other input.
- [Node-RED flow definition](config/node-red/flows.json)

### 2. Node-RED Orchestration
- Node-RED receives the file, sends it to the OCR API.
- [Node-RED OCR automation flow](config/node-red/flows.json)

### 3. OCR API Service
- Receives the PDF, extracts text using OCRmyPDF, and returns the result as JSON.
- [OCR API implementation](docker/ocr-api/app.py)
- [OCR API Dockerfile](docker/ocr-api/Dockerfile)

### 4. Bash Test Script
- Test the OCR API from the command line with a sample PDF.
- [Test script](scripts/test_ocr_api.sh)

### 5. Configuration & Compose
- All services are orchestrated via Docker Compose.
- [docker-compose.yml](docker-compose.yml)
- [Environment variables](.env)

---

## 🚦 Step-by-Step Example

1. **Start all services**:
   ```bash
   make dev
   ```
2. **Upload a PDF for OCR via Node-RED**:
   - POST a PDF to [http://localhost:1880/start-ocr](http://localhost:1880/start-ocr)
   - Example with curl:
     ```bash
     curl -X POST -F "file=@/path/to/your.pdf" http://localhost:1880/start-ocr
     ```
3. **Directly test OCR API**:
   - Use the [test script](scripts/test_ocr_api.sh):
     ```bash
     ./scripts/test_ocr_api.sh /path/to/your.pdf
     ```
   - Or use the web form at [http://localhost:8081/](http://localhost:8081/)

---

## 🔗 Key Files and Links
- [Node-RED flows.json](config/node-red/flows.json)
- [OCR API Python app.py](docker/ocr-api/app.py)
- [OCR API Dockerfile](docker/ocr-api/Dockerfile)
- [OCR Bash Test Script](scripts/test_ocr_api.sh)
- [docker-compose.yml](docker-compose.yml)
- [Makefile](Makefile)
- [Environment Variables](.env)

---

## 📁 Directory Structure

```
.
├── config/                  # Service configurations
│   ├── elasticsearch/       # Elasticsearch config
│   ├── grafana/             # Grafana dashboards and config
│   ├── node-red/            # Node-RED flows and settings
│   └── prometheus/          # Prometheus config
├── data/                    # Persistent data
│   ├── elasticsearch/       # ES data
│   ├── grafana/             # Grafana data
│   ├── minio/               # MinIO data
│   └── redis/               # Redis data
├── docker/ocr-api/          # OCR API implementation
├── scripts/                 # Utility scripts
├── docker-compose.yml       # Main compose file
├── Makefile                 # Project commands
└── .env                     # Environment variables
```

---

## 🛠️ Configuration

Create a `.env` file with the following variables (see `.env.example` for more):

```bash
OCR_HOST=ocr
OCR_PORT=8081
# ... other variables ...
```

---

## 🧑‍💻 Contributing & Maintenance
- Use `make help` to see all available commands.
- To update services:
  ```bash
  git pull origin main
  make dev
  ```
- To view logs:
  ```bash
  docker-compose logs -f
  ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, open an issue in the GitHub repository or contact the maintainers.
