#!/usr/bin/env python3
"""
Document Processing Center - Dashboard Generator
Generates user-friendly HTML dashboard from .env configuration
Usage: python generate-dashboard.py [--env-file .env] [--output web/]
"""

import os
import json
import re
from datetime import datetime
from pathlib import Path
import argparse


class DashboardGenerator:
    def __init__(self, env_file='.env', output_dir='web'):
        self.env_file = env_file
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.config = self.load_env_config()
        self.timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def load_env_config(self):
        """Load configuration from .env file"""
        config = {}

        if not os.path.exists(self.env_file):
            print(f"Warning: {self.env_file} not found, using defaults")
            return self.get_default_config()

        with open(self.env_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, _, value = line.partition('=')
                    config[key.strip()] = value.strip()

        return config

    def get_default_config(self):
        """Default configuration values"""
        return {
            'ELASTICSEARCH_HTTP_PORT': '9200',
            'KIBANA_PORT': '5601',
            'TIKA_PORT': '9998',
            'MINIO_API_PORT': '9000',
            'MINIO_CONSOLE_PORT': '9001',
            'NODE_RED_PORT': '1880',
            'OLLAMA_PORT': '11437',
            'REDIS_PORT': '6378',
            'MINIO_ROOT_USER': 'minioadmin',
            'MINIO_ROOT_PASSWORD': 'minioadmin123'
        }

    def get_service_urls(self):
        """Generate service URLs from config"""
        base_host = 'localhost'  # Change if running remotely

        return {
            'elasticsearch': f"http://{base_host}:{self.config.get('ELASTICSEARCH_HTTP_PORT', '9200')}",
            'kibana': f"http://{base_host}:{self.config.get('KIBANA_PORT', '5601')}",
            'tika': f"http://{base_host}:{self.config.get('TIKA_PORT', '9998')}",
            'minio_console': f"http://{base_host}:{self.config.get('MINIO_CONSOLE_PORT', '9001')}",
            'node_red': f"http://{base_host}:{self.config.get('NODE_RED_PORT', '1880')}",
            'ollama': f"http://{base_host}:{self.config.get('OLLAMA_PORT', '11437')}"
        }

    def generate_main_dashboard(self):
        """Generate main dashboard HTML"""
        urls = self.get_service_urls()

        template = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DocPro - Document Processing Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {{
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --card-shadow: 0 8px 32px rgba(0,0,0,0.1);
            --hover-shadow: 0 12px 40px rgba(0,0,0,0.2);
        }}

        body {{ 
            background: var(--primary-gradient); 
            min-height: 100vh; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }}

        .dashboard-card {{ 
            background: rgba(255,255,255,0.95); 
            backdrop-filter: blur(10px);
            border: none;
            box-shadow: var(--card-shadow);
            border-radius: 15px;
        }}

        .service-card {{ 
            transition: all 0.3s ease;
            cursor: pointer;
            height: 100%;
        }}

        .service-card:hover {{ 
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
        }}

        .status-online {{ color: #28a745; }}
        .status-offline {{ color: #dc3545; }}
        .status-checking {{ color: #ffc107; }}

        .feature-icon {{ 
            font-size: 3rem; 
            margin-bottom: 1rem; 
        }}

        .stat-card {{ 
            text-align: center; 
            padding: 2rem 1rem; 
        }}

        .nav-pills .nav-link.active {{ 
            background: linear-gradient(45deg, #667eea, #764ba2); 
        }}

        .navbar {{ 
            background: rgba(0,0,0,0.2) !important; 
            backdrop-filter: blur(10px);
        }}

        .service-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }}

        .quick-action-btn {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            border: none;
            color: white;
            padding: 1rem;
            border-radius: 10px;
            transition: all 0.3s ease;
        }}

        .quick-action-btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
            color: white;
        }}
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center" href="#">
                <i class="fas fa-file-alt me-2 fs-4"></i>
                <span class="fw-bold">DocPro</span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="#overview"><i class="fas fa-home me-1"></i>Overview</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#services"><i class="fas fa-server me-1"></i>Services</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#actions"><i class="fas fa-bolt me-1"></i>Actions</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#docs"><i class="fas fa-book me-1"></i>Docs</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container py-4">
        <!-- System Status Alert -->
        <div id="systemAlert" class="alert alert-info alert-dismissible fade show" role="alert">
            <i class="fas fa-circle-notch fa-spin me-2"></i>
            <strong>System Status:</strong> <span id="systemStatus">Checking services...</span>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>

        <!-- Overview Section -->
        <section id="overview" class="mb-5">
            <div class="card dashboard-card">
                <div class="card-body p-5">
                    <div class="text-center mb-5">
                        <h1 class="display-4 fw-bold text-primary mb-3">
                            <i class="fas fa-cogs me-3"></i>Document Processing Center
                        </h1>
                        <p class="lead text-muted">
                            Intelligent document processing with AI-powered analysis, 
                            compliance monitoring, and automated workflows.
                        </p>
                    </div>

                    <!-- Quick Stats -->
                    <div class="row g-4">
                        <div class="col-lg-3 col-md-6">
                            <div class="stat-card">
                                <div class="feature-icon text-primary">
                                    <i class="fas fa-file-upload"></i>
                                </div>
                                <h3 id="documentsProcessed" class="fw-bold">--</h3>
                                <p class="text-muted mb-0">Documents Processed</p>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6">
                            <div class="stat-card">
                                <div class="feature-icon text-success">
                                    <i class="fas fa-check-circle"></i>
                                </div>
                                <h3 id="complianceRate" class="fw-bold">--%</h3>
                                <p class="text-muted mb-0">Compliance Rate</p>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6">
                            <div class="stat-card">
                                <div class="feature-icon text-warning">
                                    <i class="fas fa-exclamation-triangle"></i>
                                </div>
                                <h3 id="alertsActive" class="fw-bold">--</h3>
                                <p class="text-muted mb-0">Active Alerts</p>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6">
                            <div class="stat-card">
                                <div class="feature-icon text-info">
                                    <i class="fas fa-clock"></i>
                                </div>
                                <h3 id="avgProcessingTime" class="fw-bold">-- sec</h3>
                                <p class="text-muted mb-0">Avg Processing Time</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Services Section -->
        <section id="services" class="mb-5">
            <h2 class="text-white mb-4 fw-bold">
                <i class="fas fa-server me-2"></i>Services & Tools
            </h2>

            <div class="service-grid">
                <!-- Node-RED -->
                <div class="card service-card dashboard-card" onclick="openService('{urls['node_red']}')">
                    <div class="card-body text-center p-4">
                        <div class="feature-icon text-danger">
                            <i class="fas fa-project-diagram"></i>
                        </div>
                        <h5 class="fw-bold">Node-RED Workflows</h5>
                        <p class="text-muted">Visual workflow designer for document processing pipelines</p>
                        <div class="mt-3">
                            <span class="badge bg-light text-dark">Port: {self.config.get('NODE_RED_PORT', '1880')}</span>
                            <span id="node-red-status" class="badge bg-warning ms-2">
                                <i class="fas fa-circle status-checking"></i> Checking...
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Kibana -->
                <div class="card service-card dashboard-card" onclick="openService('{urls['kibana']}')">
                    <div class="card-body text-center p-4">
                        <div class="feature-icon text-success">
                            <i class="fas fa-chart-bar"></i>
                        </div>
                        <h5 class="fw-bold">Kibana Analytics</h5>
                        <p class="text-muted">Search, analyze and visualize document data</p>
                        <div class="mt-3">
                            <span class="badge bg-light text-dark">Port: {self.config.get('KIBANA_PORT', '5601')}</span>
                            <span id="kibana-status" class="badge bg-warning ms-2">
                                <i class="fas fa-circle status-checking"></i> Checking...
                            </span>
                        </div>
                    </div>
                </div>

                <!-- MinIO -->
                <div class="card service-card dashboard-card" onclick="openService('{urls['minio_console']}')">
                    <div class="card-body text-center p-4">
                        <div class="feature-icon text-primary">
                            <i class="fas fa-database"></i>
                        </div>
                        <h5 class="fw-bold">MinIO Storage</h5>
                        <p class="text-muted">Object storage for documents and processed files</p>
                        <div class="mt-3">
                            <span class="badge bg-light text-dark">Port: {self.config.get('MINIO_CONSOLE_PORT', '9001')}</span>
                            <span id="minio-status" class="badge bg-warning ms-2">
                                <i class="fas fa-circle status-checking"></i> Checking...
                            </span>
                        </div>
                        <small class="text-muted d-block mt-2">
                            Login: {self.config.get('MINIO_ROOT_USER', 'minioadmin')} / {self.config.get('MINIO_ROOT_PASSWORD', 'minioadmin123')}
                        </small>
                    </div>
                </div>

                <!-- Elasticsearch -->
                <div class="card service-card dashboard-card" onclick="openService('{urls['elasticsearch']}/_cat/indices?v')">
                    <div class="card-body text-center p-4">
                        <div class="feature-icon text-warning">
                            <i class="fas fa-search"></i>
                        </div>
                        <h5 class="fw-bold">Elasticsearch</h5>
                        <p class="text-muted">Search engine and document indexing</p>
                        <div class="mt-3">
                            <span class="badge bg-light text-dark">Port: {self.config.get('ELASTICSEARCH_HTTP_PORT', '9200')}</span>
                            <span id="elasticsearch-status" class="badge bg-warning ms-2">
                                <i class="fas fa-circle status-checking"></i> Checking...
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Tika -->
                <div class="card service-card dashboard-card" onclick="testTika()">
                    <div class="card-body text-center p-4">
                        <div class="feature-icon text-info">
                            <i class="fas fa-file-alt"></i>
                        </div>
                        <h5 class="fw-bold">Apache Tika</h5>
                        <p class="text-muted">Document text extraction and parsing</p>
                        <div class="mt-3">
                            <span class="badge bg-light text-dark">Port: {self.config.get('TIKA_PORT', '9998')}</span>
                            <span id="tika-status" class="badge bg-warning ms-2">
                                <i class="fas fa-circle status-checking"></i> Checking...
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Ollama AI -->
                <div class="card service-card dashboard-card" onclick="testOllama()">
                    <div class="card-body text-center p-4">
                        <div class="feature-icon" style="color: #8b5cf6;">
                            <i class="fas fa-brain"></i>
                        </div>
                        <h5 class="fw-bold">Ollama AI</h5>
                        <p class="text-muted">Local AI models for document analysis</p>
                        <div class="mt-3">
                            <span class="badge bg-light text-dark">Port: {self.config.get('OLLAMA_PORT', '11437')}</span>
                            <span id="ollama-status" class="badge bg-warning ms-2">
                                <i class="fas fa-circle status-checking"></i> Checking...
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Quick Actions -->
        <section id="actions" class="mb-5">
            <h2 class="text-white mb-4 fw-bold">
                <i class="fas fa-bolt me-2"></i>Quick Actions
            </h2>
            <div class="row g-3">
                <div class="col-lg-3 col-md-6">
                    <button class="btn quick-action-btn w-100 h-100" onclick="uploadDocument()">
                        <i class="fas fa-upload me-2"></i>
                        <div>Upload Document</div>
                    </button>
                </div>
                <div class="col-lg-3 col-md-6">
                    <button class="btn quick-action-btn w-100 h-100" onclick="viewRecentDocs()">
                        <i class="fas fa-clock me-2"></i>
                        <div>Recent Documents</div>
                    </button>
                </div>
                <div class="col-lg-3 col-md-6">
                    <button class="btn quick-action-btn w-100 h-100" onclick="viewAlerts()">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <div>View Alerts</div>
                    </button>
                </div>
                <div class="col-lg-3 col-md-6">
                    <button class="btn quick-action-btn w-100 h-100" onclick="showSystemInfo()">
                        <i class="fas fa-info-circle me-2"></i>
                        <div>System Info</div>
                    </button>
                </div>
            </div>
        </section>

        <!-- Configuration Display -->
        <section class="mb-5">
            <div class="card dashboard-card">
                <div class="card-body">
                    <h4><i class="fas fa-cog me-2"></i>System Configuration</h4>
                    <div class="row mt-3">
                        <div class="col-md-6">
                            <h6>Service Ports</h6>
                            <ul class="list-unstyled">
                                <li><strong>Elasticsearch:</strong> {self.config.get('ELASTICSEARCH_HTTP_PORT', '9200')}</li>
                                <li><strong>Kibana:</strong> {self.config.get('KIBANA_PORT', '5601')}</li>
                                <li><strong>MinIO Console:</strong> {self.config.get('MINIO_CONSOLE_PORT', '9001')}</li>
                                <li><strong>Node-RED:</strong> {self.config.get('NODE_RED_PORT', '1880')}</li>
                                <li><strong>Tika:</strong> {self.config.get('TIKA_PORT', '9998')}</li>
                                <li><strong>Ollama:</strong> {self.config.get('OLLAMA_PORT', '11437')}</li>
                            </ul>
                        </div>
                        <div class="col-md-6">
                            <h6>AI Configuration</h6>
                            <ul class="list-unstyled">
                                <li><strong>Model:</strong> {self.config.get('LLM_MODEL', 'llama2:13b')}</li>
                                <li><strong>Temperature:</strong> {self.config.get('LLM_TEMPERATURE', '0.1')}</li>
                                <li><strong>Confidence Threshold:</strong> {self.config.get('CONFIDENCE_THRESHOLD', '0.8')}</li>
                                <li><strong>Max Document Size:</strong> {self.config.get('MAX_DOCUMENT_SIZE', '50MB')}</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="text-center text-white-50 mt-5 py-3">
            <p class="mb-0">
                DocPro Dashboard | Generated: {self.timestamp} | 
                <a href="mailto:admin@company.com" class="text-white-50">Contact Support</a>
            </p>
        </footer>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        const services = {urls};

        function updateServiceStatus(service, isOnline) {{
            const statusElement = document.getElementById(service + '-status');
            if (statusElement) {{
                if (isOnline) {{
                    statusElement.innerHTML = '<i class="fas fa-circle status-online"></i> Online';
                    statusElement.className = 'badge bg-success ms-2';
                }} else {{
                    statusElement.innerHTML = '<i class="fas fa-circle status-offline"></i> Offline';
                    statusElement.className = 'badge bg-danger ms-2';
                }}
            }}
        }}

        async function checkService(name, url) {{
            try {{
                const response = await fetch(url, {{ 
                    method: 'GET', 
                    mode: 'no-cors',
                    timeout: 5000 
                }});
                updateServiceStatus(name, true);
                return true;
            }} catch (error) {{
                updateServiceStatus(name, false);
                return false;
            }}
        }}

        async function checkAllServices() {{
            const serviceNames = Object.keys(services);
            let onlineCount = 0;

            for (const [name, url] of Object.entries(services)) {{
                const isOnline = await checkService(name.replace('_', '-'), url);
                if (isOnline) onlineCount++;
            }}

            updateSystemStatus(onlineCount, serviceNames.length);
        }}

        function updateSystemStatus(online, total) {{
            const percentage = Math.round((online / total) * 100);
            const statusText = document.getElementById('systemStatus');
            const alert = document.getElementById('systemAlert');

            if (percentage === 100) {{
                statusText.textContent = `All services online ({{online}}/{{total}}) ✅`;
                alert.className = 'alert alert-success alert-dismissible fade show';
            }} else if (percentage >= 80) {{
                statusText.textContent = `Most services online ({{online}}/{{total}}) ⚠️`;
                alert.className = 'alert alert-warning alert-dismissible fade show';
            }} else {{
                statusText.textContent = `Some services offline ({{online}}/{{total}}) ❌`;
                alert.className = 'alert alert-danger alert-dismissible fade show';
            }}
        }}

        function loadStatistics() {{
            // Simulate loading - replace with real API calls
            setTimeout(() => {{
                document.getElementById('documentsProcessed').textContent = '1,234';
                document.getElementById('complianceRate').textContent = '95%';
                document.getElementById('alertsActive').textContent = '3';
                document.getElementById('avgProcessingTime').textContent = '2.5';
            }}, 1000);
        }}

        function openService(url) {{
            window.open(url, '_blank');
        }}

        function uploadDocument() {{
            alert('📁 To upload documents:\\n\\n1. Copy files to data/input/ folder\\n2. Use Node-RED file upload flow\\n3. Drag & drop to MinIO console');
        }}

        function viewRecentDocs() {{
            openService(services.kibana + '/app/discover');
        }}

        function viewAlerts() {{
            openService(services.kibana + '/app/discover#/?_g=(filters:!(),time:(from:now-24h,to:now))&_a=(filters:!(),index:compliance-alerts)');
        }}

        function showSystemInfo() {{
            const info = `DocPro System Information:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Service URLs:
• Elasticsearch: {urls['elasticsearch']}
• Kibana: {urls['kibana']}
• MinIO Console: {urls['minio_console']}
• Node-RED: {urls['node_red']}
• Tika: {urls['tika']}
• Ollama: {urls['ollama']}

🔧 Configuration:
• Project: {self.config.get('COMPOSE_PROJECT_NAME', 'docpro')}
• Network: {self.config.get('NETWORK_NAME', 'doc-net')}
• Timezone: {self.config.get('TZ', 'Europe/Warsaw')}
• Max Doc Size: {self.config.get('MAX_DOCUMENT_SIZE', '50MB')}

📊 Generated: {self.timestamp}`;
            alert(info);
        }}

        async function testTika() {{
            try {{
                const response = await fetch(services.tika + '/tika', {{
                    method: 'PUT',
                    body: 'Hello, this is a test document for Tika parsing.',
                    headers: {{'Content-Type': 'text/plain'}}
                }});
                const result = await response.text();
                alert('✅ Tika Test Successful:\\n\\n' + result);
            }} catch (error) {{
                alert('❌ Tika Test Failed:\\n\\n' + error.message);
            }}
        }}

        async function testOllama() {{
            try {{
                const response = await fetch(services.ollama + '/api/tags');
                const data = await response.json();
                const models = data.models || [];
                alert('🤖 Available Ollama Models:\\n\\n' + 
                      models.map(m => `• ${{m.name}} (${{m.size || 'unknown size'}})`).join('\\n') ||
                      'No models found');
            }} catch (error) {{
                alert('❌ Ollama Test Failed:\\n\\n' + error.message);
            }}
        }}

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {{
            checkAllServices();
            loadStatistics();
        }});

        // Auto-refresh every 30 seconds
        setInterval(checkAllServices, 30000);
    </script>
</body>
</html>"""

        return template

    def generate(self):
        """Generate all documentation files"""
        print(f"📄 Generating DocPro dashboard from {self.env_file}...")

        # Generate main dashboard
        dashboard_html = self.generate_main_dashboard()
        dashboard_file = self.output_dir / 'index.html'
        with open(dashboard_file, 'w', encoding='utf-8') as f:
            f.write(dashboard_html)
        print(f"✅ Generated: {dashboard_file}")

        # Generate config summary
        config_file = self.output_dir / 'config.json'
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(self.config, f, indent=2)
        print(f"✅ Generated: {config_file}")

        # Generate URLs list
        urls = self.get_service_urls()
        urls_file = self.output_dir / 'urls.txt'
        with open(urls_file, 'w') as f:
            f.write(f"DocPro Service URLs (Generated: {self.timestamp})\\n")
            f.write("=" * 50 + "\\n\\n")
            for service, url in urls.items():
                f.write(f"{service.replace('_', ' ').title()}: {url}\\n")
        print(f"✅ Generated: {urls_file}")

        print(f"\\n🎉 Dashboard ready at: {dashboard_file}")
        print(f"📂 Output directory: {self.output_dir.absolute()}")


def main():
    parser = argparse.ArgumentParser(description='Generate DocPro HTML Dashboard')
    parser.add_argument('--env-file', default='.env', help='Path to .env file')
    parser.add_argument('--output', default='web', help='Output directory')
    parser.add_argument('--serve', action='store_true', help='Start local web server')

    args = parser.parse_args()

    generator = DashboardGenerator(args.env_file, args.output)
    generator.generate()

    if args.serve:
        import http.server
        import socketserver
        import webbrowser
        import os

        os.chdir(args.output)
        PORT = 8000

        Handler = http.server.SimpleHTTPRequestHandler
        with socketserver.TCPServer(("", PORT), Handler) as httpd:
            print(f"\\n🌐 Serving dashboard at http://localhost:{PORT}")
            webbrowser.open(f'http://localhost:{PORT}')
            httpd.serve_forever()


if __name__ == '__main__':
    main()