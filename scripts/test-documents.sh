#!/bin/bash

echo "🧪 Testing Document Processing Pipeline..."

# Create test input directory
mkdir -p data/input

# Test 1: Create a sample COR document
echo "📄 Creating sample COR document..."
cat > data/input/sample-cor-certificate.txt << 'EOF'
CERTIFICATE OF CONFORMITY

Certificate Number: COR-2024-EU-987654
Issuing Authority: European Conformity Assessment Body (ECAB)
Date of Issue: 2024-01-15

Product Information:
Product Name: Industrial Safety Valve Model SV-3000
Manufacturer: Advanced Safety Systems Ltd.
Model Number: SV-3000-PRO
Serial Number: SV3000-2024-001
Batch/Lot Number: LOT-2024-Q1-001

Technical Specifications:
- Operating Pressure: 0-300 PSI
- Temperature Range: -40°C to +150°C
- Material: Stainless Steel 316L
- Size: DN25 (1 inch)
- End Connections: NPT Threaded

Applicable Standards and Regulations:
✅ EN ISO 12100:2010 (Safety of machinery - General principles for design)
✅ EN 60204-1:2018 (Safety of machinery - Electrical equipment)
✅ Pressure Equipment Directive 2014/68/EU (PED)
✅ ATEX Directive 2014/34/EU (Equipment for explosive atmospheres)
✅ Machine Directive 2006/42/EC

Test Results:
✅ Pressure Test: PASSED (Test Pressure: 450 PSI, Duration: 30 minutes)
✅ Leakage Test: PASSED (No detectable leakage at operating pressure)
✅ Material Verification: PASSED (Material certificates provided)
✅ Dimensional Check: PASSED (All dimensions within tolerance)
✅ Function Test: PASSED (Valve operation verified)
✅ Documentation Review: PASSED

⚠️  MINOR ISSUE DETECTED:
- Operating manual available only in English
- Translation to local language recommended for installation site

Validity Period:
Valid From: 2024-01-15
Valid Until: 2025-01-15

This certificate confirms that the above product meets all essential safety
requirements and applicable standards for use in the European Union.

Authorized Signature: Dr. Michael Schmidt
Title: Lead Certification Engineer
Date: 2024-01-15
Certification Body Registration: ECAB-001-2024

IMPORTANT: This certificate is only valid for the specific product and
serial number listed above. Any modifications to the product will void
this certification.
EOF

# Test 2: Create a sample invoice
echo "💰 Creating sample invoice..."
cat > data/input/sample-invoice-12500.txt << 'EOF'
INVOICE

Invoice Number: INV-2024-001567
Invoice Date: 2024-01-22
Due Date: 2024-02-22

BILL TO:
Manufacturing Excellence Corp.
123 Industrial Drive
Production City, PC 12345-6789
VAT Number: EU123456789

REMIT TO:
Premium Suppliers Ltd.
456 Supply Chain Avenue
Vendor Valley, VV 98765-4321
VAT Number: EU987654321
Bank Account: IBAN GB29 NWBK 6016 1331 9268 19

PURCHASE ORDER: PO-2024-0089
DELIVERY NOTE: DN-2024-0234

ITEMS:
1. Industrial Control Valves (Model SV-3000-PRO)
   Quantity: 25 units
   Unit Price: €450.00
   Line Total: €11,250.00

2. Installation and Commissioning Service
   Quantity: 1 service
   Unit Price: €1,500.00
   Line Total: €1,500.00

3. Extended Warranty (3 years)
   Quantity: 25 units
   Unit Price: €75.00
   Line Total: €1,875.00

4. Technical Documentation and Training
   Quantity: 1 package
   Unit Price: €650.00
   Line Total: €650.00

SUBTOTAL: €15,275.00
VAT (21%): €3,207.75
SHIPPING: €125.00
TOTAL AMOUNT: €18,607.75 EUR

⚠️  HIGH VALUE ALERT: This invoice exceeds €10,000 threshold
Approval Required: Finance Director

Payment Terms: Net 30 days
Late Payment: 2% per month on overdue amounts
Payment Method: Bank Transfer Only

Special Instructions:
- Delivery required by 2024-02-15
- Installation to be coordinated with Plant Manager
- All equipment requires CE certification
- Invoice processing contact: finance@manufacturing-excellence.com

Authorized by: Sarah Johnson, Sales Manager
Date: 2024-01-22
EOF

# Test 3: Create a sample contract
echo "📋 Creating sample contract..."
cat > data/input/sample-contract-high-risk.txt << 'EOF'
SERVICE AGREEMENT

Contract Number: SA-2024-0156
Date: January 20, 2024

PARTIES:
Client: Global Manufacturing Inc.
Address: 789 Enterprise Blvd, Business City, BC 54321
Contact: John Director, Operations Director

Service Provider: TechSolutions Consulting Ltd.
Address: 321 Innovation Street, Tech Town, TT 13579
Contact: Maria Consultant, Project Manager

CONTRACT TERMS:

1. SCOPE OF SERVICES:
Implementation of Enterprise Resource Planning (ERP) system including:
- System analysis and design
- Software customization and configuration
- Data migration from legacy systems
- Staff training and documentation
- Go-live support and warranty

2. PROJECT TIMELINE:
Start Date: February 1, 2024
Completion Date: August 31, 2024
⚠️  CRITICAL: Project duration 7 months with tight deadline

3. FINANCIAL TERMS:
Total Contract Value: €485,000
Payment Schedule:
- 30% upon contract signing: €145,500
- 40% upon system testing completion: €194,000
- 30% upon go-live and acceptance: €145,500

⚠️  HIGH RISK FACTORS IDENTIFIED:
- Large upfront payment (30% = €145,500)
- No performance guarantees specified
- Limited liability clause favors service provider

4. DELIVERABLES:
- Functional ERP system
- Data migration (100% accuracy required)
- User training for 50+ employees
- Technical documentation
- 6-month warranty period

5. RISKS AND LIABILITIES:
⚠️  CRITICAL RISK CLAUSE:
"Service Provider's liability shall not exceed 50% of total contract value"
Maximum liability: €242,500

6. TERMINATION CONDITIONS:
- Either party may terminate with 30 days notice
- Client liable for work completed plus 20% penalty
- ⚠️  UNFAVORABLE: High termination penalty for client

7. INTELLECTUAL PROPERTY:
- All customizations become property of Service Provider
- ⚠️  RISK: Client loses ownership of custom developments
- Limited usage rights granted to Client

8. DISPUTE RESOLUTION:
Jurisdiction: Service Provider's country (favorable to provider)
Arbitration required before court proceedings

⚠️  OVERALL RISK ASSESSMENT: HIGH
Recommendation: Legal review required before signing
Key concerns: High upfront payment, limited liability, unfavorable IP terms

Signatures:
Client: _________________ Date: _________
Service Provider: _________________ Date: _________

LEGAL REVIEW STATUS: PENDING - HIGH PRIORITY
EOF

echo "📁 Sample documents created in data/input/"
echo "🔄 Documents will be processed automatically by the pipeline"
echo "📊 Monitor progress in Kibana: http://localhost:5601"
echo "🗄️  Check storage in MinIO: http://localhost:9001"

# Wait a moment for processing
sleep 10

echo "🔍 Checking processing status..."
curl -s "http://localhost:9200/documents/_search?q=*&size=0" | grep -o '"total":{"value":[0-9]*' | grep -o '[0-9]*rf: true" \
  -d '{
    "attributes": {
      "title": "documents*",
      "timeFieldName": "processing_timestamp"
    }
  }'

curl -X POST "localhost:5601/api/saved_objects/index-pattern" \
  -H "Content-Type: application/json" \
  -H "kbn-xs | head -1 | while read count; do
    echo "📈 Documents processed: $count"
done

curl -s "http://localhost:9200/compliance-alerts/_search?q=*&size=0" | grep -o '"total":{"value":[0-9]*' | grep -o '[0-9]*rf: true" \
  -d '{
    "attributes": {
      "title": "documents*",
      "timeFieldName": "processing_timestamp"
    }
  }'

curl -X POST "localhost:5601/api/saved_objects/index-pattern" \
  -H "Content-Type: application/json" \
  -H "kbn-xs | head -1 | while read count; do
    echo "🚨 Alerts generated: $count"
done