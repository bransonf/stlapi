#!./env/bin/python3
# Flask API for Serving STL Data
from flask import Flask, render_template, jsonify, request
from flask_api import status
from flask_cors import CORS

from os import environ

import yaml
import psycopg2

# load creds
with open(r'../creds.yml') as file:
    creds = yaml.safe_load(file)

# connect to database
dbcon = psycopg2.connect(host = creds['host'],
                        database = creds['database'],
                        user = creds['username'],
                        password = creds['password'])

from crime_queries import coords

# initialize flask
app = Flask(__name__)
CORS(app) # Add Cors Exception

# Define Index
@app.route('/')
def index():
    return render_template('index.html')

# Define Crime Endpoints
@app.route('/crime/coords')
def crimecoords():
    # Get URL Params
    start = request.args.get('start',None)
    end = request.args.get('end',None)
    category = request.args.get('category', 'all')
    proj = request.args.get('proj','wgs')
    unfounded = request.args.get('unfounded',False)

    rsp = coords(dbcon, start, end, category, proj, unfounded)

    return jsonify(rsp)


# import the crime endpoint functions
# sanitize url input

# Run the App
if __name__ == "__main__":
    app.run(host = '0.0.0.0', debug=True)