FROM jbarlow83/ocrmypdf:latest
RUN pip install flask
COPY app.py /app/app.py
WORKDIR /app
EXPOSE 8080
CMD ["python3", "app.py"]
