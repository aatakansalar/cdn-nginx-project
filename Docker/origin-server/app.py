from flask import Flask, send_from_directory, abort
import os

app = Flask(__name__)

IMAGE_DIR = os.path.join(app.root_path, 'images')

@app.route('/images/<path:filename>')
def serve_image(filename):
    if os.path.isfile(os.path.join(IMAGE_DIR, filename)):
        return send_from_directory(IMAGE_DIR, filename)
    else:
        abort(404)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
