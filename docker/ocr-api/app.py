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
                'ocrmypdf', '--force-ocr', '--sidecar', output_path + '.txt', input_file.name, output_path
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

@app.route('/', methods=['GET'])
def index():
    return '''
    <!doctype html>
    <title>OCR PDF Upload</title>
    <h1>Upload PDF for OCR</h1>
    <form method="post" action="/ocr" enctype="multipart/form-data">
      <input type="file" name="file" accept="application/pdf">
      <input type="submit" value="Upload">
    </form>
    <pre id="result"></pre>
    <script>
    document.querySelector('form').onsubmit = async function(e) {
      e.preventDefault();
      const form = e.target;
      const data = new FormData(form);
      const res = await fetch('/ocr', { method: 'POST', body: data });
      const json = await res.json();
      document.getElementById('result').textContent = json.text || json.error;
    };
    </script>
    '''

@app.route('/health', methods=['GET'])
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
