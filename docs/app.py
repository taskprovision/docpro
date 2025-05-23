#!/usr/bin/env python3
"""
DocPro - FastAPI Dashboard
Real-time service monitoring dashboard with live status checking
"""

from fastapi import FastAPI, Request, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, JSONResponse
import os
import asyncio
import aiohttp
import yaml
from pathlib import Path
from typing import Dict, List, Optional
import logging
from datetime import datetime
import json

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="DocPro Dashboard", description="Service monitoring dashboard")

# Setup templates and static files
templates = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")


class ConfigLoader:
    def __init__(self, env_file=".env", compose_file="docker-compose.yml"):
        self.env_file = env_file
        self.compose_file = compose_file
        self.config = self.load_env_config()
        self.services = self.load_docker_services()

    def load_env_config(self) -> Dict[str, str]:
        """Load environment variables from .env file"""
        config = {}
        if os.path.exists(self.env_file):
            with open(self.env_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, _, value = line.partition('=')
                        config[key.strip()] = value.strip()
        return config

    def load_docker_services(self) -> Dict[str, Dict]:
        """Load service information from docker-compose.yml"""
        services = {}
        if os.path.exists(self.compose_file):
            try:
                with open(self.compose_file, 'r') as f:
                    compose_data = yaml.safe_load(f)
                    if 'services' in compose_data:
                        for service_name, service_config in compose_data['services'].items():
                            ports = service_config.get('ports', [])
                            if ports:
                                # Extract port mapping (e.g., "9200:9200" -> 9200)
                                host_port = ports[0].split(':')[0] if ':' in str(ports[0]) else ports[0]
                                services[service_name] = {
                                    'port': int(host_port),
                                    'image': service_config.get('image', 'unknown'),
                                    'container_name': service_config.get('container_name', service_name)
                                }
            except Exception as e:
                logger.error(f"Error loading docker-compose.yml: {e}")
        return services

    def get_service_url(self, service_name: str, host: str = "localhost") -> Optional[str]:
        """Get service URL based on configuration"""
        port_mappings = {
            'elasticsearch': self.config.get('ELASTICSEARCH_HTTP_PORT', '9200'),
            'kibana': self.config.get('KIBANA_PORT', '5601'),
            'node-red': self.config.get('NODE_RED_PORT', '1880'),
            'minio': self.config.get('MINIO_CONSOLE_PORT', '9001'),
            'tika': self.config.get('TIKA_PORT', '9998'),
            'ollama': self.config.get('OLLAMA_PORT', '11437'),
            'redis': self.config.get('REDIS_PORT', '6378'),
            'ocr': self.config.get('OCR_PORT', '8082')
        }

        port = port_mappings.get(service_name)
        if port:
            return f"http://{host}:{port}"

        # Fallback to docker-compose services
        if service_name in self.services:
            port = self.services[service_name]['port']
            return f"http://{host}:{port}"

        return None


# Global config loader
config_loader = ConfigLoader()


class ServiceMonitor:
    def __init__(self, config_loader: ConfigLoader):
        self.config_loader = config_loader
        self.service_definitions = {
            'elasticsearch': {
                'name': 'Elasticsearch',
                'description': 'Search engine and document indexing',
                'icon': 'fas fa-search',
                'color': 'warning',
                'health_endpoint': '/_cluster/health',
                'category': 'Core'
            },
            'kibana': {
                'name': 'Kibana Analytics',
                'description': 'Data visualization and analytics dashboard',
                'icon': 'fas fa-chart-bar',
                'color': 'success',
                'health_endpoint': '/api/status',
                'category': 'Analytics'
            },
            'node-red': {
                'name': 'Node-RED',
                'description': 'Visual workflow designer and processing engine',
                'icon': 'fas fa-project-diagram',
                'color': 'danger',
                'health_endpoint': '/',
                'category': 'Processing'
            },
            'minio': {
                'name': 'MinIO Storage',
                'description': 'Object storage for documents and files',
                'icon': 'fas fa-database',
                'color': 'primary',
                'health_endpoint': '/minio/health/live',
                'category': 'Storage'
            },
            'tika': {
                'name': 'Apache Tika',
                'description': 'Document text extraction and parsing',
                'icon': 'fas fa-file-alt',
                'color': 'info',
                'health_endpoint': '/tika',
                'category': 'Processing'
            },
            'ollama': {
                'name': 'Ollama AI',
                'description': 'Local AI models for document analysis',
                'icon': 'fas fa-brain',
                'color': 'purple',
                'health_endpoint': '/api/tags',
                'category': 'AI'
            },
            'redis': {
                'name': 'Redis Cache',
                'description': 'In-memory data structure store',
                'icon': 'fas fa-memory',
                'color': 'dark',
                'health_endpoint': '/',
                'category': 'Cache'
            },
            'ocr': {
                'name': 'OCR Service',
                'description': 'Optical Character Recognition for images',
                'icon': 'fas fa-eye',
                'color': 'secondary',
                'health_endpoint': '/',
                'category': 'Processing'
            }
        }

    async def check_service_health(self, service_name: str, url: str, health_endpoint: str = '/') -> Dict:
        """Check health of a single service"""
        try:
            timeout = aiohttp.ClientTimeout(total=5)
            async with aiohttp.ClientSession(timeout=timeout) as session:
                health_url = f"{url}{health_endpoint}"
                async with session.get(health_url) as response:
                    status = 'online' if response.status < 400 else 'degraded'
                    response_time = None
                    return {
                        'status': status,
                        'response_time': response_time,
                        'status_code': response.status,
                        'error': None
                    }
        except Exception as e:
            return {
                'status': 'offline',
                'response_time': None,
                'status_code': None,
                'error': str(e)
            }

    async def get_all_services_status(self) -> List[Dict]:
        """Get status of all configured services"""
        services_status = []

        for service_name, service_def in self.service_definitions.items():
            url = self.config_loader.get_service_url(service_name)

            if url:
                health_data = await self.check_service_health(
                    service_name,
                    url,
                    service_def.get('health_endpoint', '/')
                )

                service_info = {
                    'name': service_name,
                    'display_name': service_def['name'],
                    'description': service_def['description'],
                    'icon': service_def['icon'],
                    'color': service_def['color'],
                    'category': service_def['category'],
                    'url': url,
                    'port': url.split(':')[-1] if ':' in url else 'unknown',
                    **health_data
                }
                services_status.append(service_info)
            else:
                # Service not configured
                service_info = {
                    'name': service_name,
                    'display_name': service_def['name'],
                    'description': service_def['description'],
                    'icon': service_def['icon'],
                    'color': service_def['color'],
                    'category': service_def['category'],
                    'url': None,
                    'port': 'not configured',
                    'status': 'not_configured',
                    'response_time': None,
                    'status_code': None,
                    'error': 'Service not configured in .env'
                }
                services_status.append(service_info)

        return services_status


# Global service monitor
service_monitor = ServiceMonitor(config_loader)


@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):
    """Main dashboard page"""
    try:
        services = await service_monitor.get_all_services_status()

        # Group services by category
        services_by_category = {}
        for service in services:
            category = service['category']
            if category not in services_by_category:
                services_by_category[category] = []
            services_by_category[category].append(service)

        # Calculate overall health
        online_count = sum(1 for s in services if s['status'] == 'online')
        total_count = len([s for s in services if s['status'] != 'not_configured'])
        health_percentage = (online_count / total_count * 100) if total_count > 0 else 0

        context = {
            "request": request,
            "services": services,
            "services_by_category": services_by_category,
            "config": config_loader.config,
            "health_percentage": round(health_percentage, 1),
            "online_count": online_count,
            "total_count": total_count,
            "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        return templates.TemplateResponse("dashboard.html", context)

    except Exception as e:
        logger.error(f"Error rendering dashboard: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/services")
async def get_services_api():
    """API endpoint to get services status"""
    try:
        services = await service_monitor.get_all_services_status()
        return {
            "services": services,
            "timestamp": datetime.now().isoformat(),
            "total_services": len(services),
            "online_services": len([s for s in services if s['status'] == 'online'])
        }
    except Exception as e:
        logger.error(f"Error getting services: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/service/{service_name}/health")
async def get_service_health(service_name: str):
    """Get health status of a specific service"""
    try:
        url = config_loader.get_service_url(service_name)
        if not url:
            raise HTTPException(status_code=404, detail=f"Service {service_name} not found")

        service_def = service_monitor.service_definitions.get(service_name, {})
        health_endpoint = service_def.get('health_endpoint', '/')

        health_data = await service_monitor.check_service_health(service_name, url, health_endpoint)

        return {
            "service": service_name,
            "url": url,
            **health_data,
            "timestamp": datetime.now().isoformat()
        }

    except Exception as e:
        logger.error(f"Error checking service {service_name}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/config")
async def get_config():
    """Get current configuration"""
    return {
        "env_config": config_loader.config,
        "docker_services": config_loader.services,
        "timestamp": datetime.now().isoformat()
    }


@app.get("/api/stats")
async def get_stats():
    """Get system statistics"""
    try:
        services = await service_monitor.get_all_services_status()

        stats = {
            "total_services": len(services),
            "online_services": len([s for s in services if s['status'] == 'online']),
            "offline_services": len([s for s in services if s['status'] == 'offline']),
            "degraded_services": len([s for s in services if s['status'] == 'degraded']),
            "not_configured": len([s for s in services if s['status'] == 'not_configured']),
            "categories": list(set(s['category'] for s in services)),
            "uptime_percentage": 0,  # Would need persistent storage to calculate
            "last_check": datetime.now().isoformat()
        }

        if stats["total_services"] > 0:
            stats["health_percentage"] = round(
                (stats["online_services"] / (stats["total_services"] - stats["not_configured"])) * 100, 1
            ) if (stats["total_services"] - stats["not_configured"]) > 0 else 0

        return stats

    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv('DASHBOARD_PORT', 8000))
    host = os.getenv('DASHBOARD_HOST', '0.0.0.0')

    print(f"🚀 Starting DocPro Dashboard on {host}:{port}")
    print(f"📊 Dashboard URL: http://localhost:{port}")

    uvicorn.run(
        "app:app",
        host=host,
        port=port,
        reload=True,
        log_level="info"
    )