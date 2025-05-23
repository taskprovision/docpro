document-processing-center/
├── install.sh
├── docker-compose.yml
├── .env.example
├── config/
│   ├── tika/tika-config.xml
│   ├── elasticsearch/elasticsearch.yml
│   ├── kibana/kibana.yml
│   ├── camel/
│   │   ├── application.properties
│   │   └── routes/document-routes.xml
│   └── minio/
│       └── bucket-policy.json
├── scripts/
│   ├── setup-indices.sh
│   ├── test-documents.sh
│   ├── upload-samples.sh
│   └── backup.sh
├── templates/
│   ├── cor-analysis.json
│   ├── invoice-analysis.json
│   └── contract-analysis.json
├── sample-docs/
│   ├── sample-cor.pdf
│   ├── sample-invoice.pdf
│   └── sample-contract.pdf
└── README.md