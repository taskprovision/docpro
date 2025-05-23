from flask import Flask, request, jsonify
import subprocess
import tempfile
import os

app = Flask(__name__)

@app.route('/ocr', methods=['POST'])
def ocr_pdf():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400
    file = request.files['file']
    with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as input_file:
        file.save(input_file.name)
        output_path = input_file.name + '.ocr.pdf'
        try:
            result = subprocess.run([
                'ocrmypdf', '--sidecar', output_path + '.txt', input_file.name, output_path
            ], capture_output=True, text=True)
            if result.returncode != 0:
                return jsonify({'error': result.stderr}), 500
            with open(output_path + '.txt', 'r') as f:
                text = f.read()
            return jsonify({'text': text})
        finally:
            os.remove(input_file.name)
            if os.path.exists(output_path):
                os.remove(output_path)
            if os.path.exists(output_path + '.txt'):
                os.remove(output_path + '.txt')

@app.route('/health', methods=['GET'])
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
