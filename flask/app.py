# Flask API for Serving STL Data
from flask import Flask, render_template, jsonify, request
from flask_api import status
from flask_cors import CORS

from os import environ

app = Flask(__name__)
CORS(app) # Add Cors Exception

# Define Index
@app.route('/')
def index():
    return render_template('index.html')

# Run the App
if __name__ == "__main__":
    app.run(host = '0.0.0.0', debug=True)