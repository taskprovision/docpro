FROM python:3.11-slim

# Install system dependencies for ocrmypdf
RUN apt-get update && \
    apt-get install -y tesseract-ocr ghostscript qpdf unpaper libjpeg-dev libpng-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir flask ocrmypdf

COPY app.py /app/app.py
WORKDIR /app
EXPOSE 8080
CMD ["python3", "app.py"]
