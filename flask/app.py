#!./env/bin/python3
# Flask API for Serving STL Data
from flask import Flask, render_template, jsonify, request
from flask_api import status
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

import os

# Import Creds (Provide as Environmental Variable or File)
with open('../pguri.cfg', 'r') as f:
    pg = os.getenv('pguri', f.read())

# Initialize Flask
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = pg
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
ma = Marshmallow(app)
CORS(app) # cors *

# Crime Table
class Crime(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    dateOccur = db.Column(db.DateTime)
    flagCrime = db.Column(db.Boolean)
    flagUnfounded = db.Column(db.Boolean)
    flagAdmin = db.Column(db.Boolean)
    count = db.Column(db.Boolean)
    crimeCode = db.Column(db.Integer)
    crimeCat = db.Column(db.Text)
    district = db.Column(db.Integer) 
    description = db.Column(db.Text)
    neighborhood = db.Column(db.Integer)
    nadX = db.Column(db.Float(8))
    nadY = db.Column(db.Float(8))
    wgsX = db.Column(db.Float(8))
    wgsY = db.Column(db.Float(8))

    def __repr__(self):
        return '<Crime %r>' % self.id

# Crime Location
class CrimeLocWGS(ma.Schema):
    class Meta:
        fields = ('id','crimeCat','wgsX','wgsY')

class CrimeLocNAD(ma.Schema):
    class Meta:
        fields = ('id','crimeCat','nadX','nadY')

# Crime Details
class CrimeDetail(ma.Schema):
    class Meta:
        fields = ('id', 'dataOccur','crimeCat','description','wgsX','wgsY')

# Define Index
@app.route('/')
def index():
    return render_template('index.html')

# Query Crime by Date Range, Category
@app.route('/crime/coords')
def crimecoords():
    start = request.args.get('start','2008-01-01')
    end = request.args.get('end',start)
    category = request.args.get('category','all')
    proj = request.args.get('proj', 'wgs')
    unfounded = request.args.get('unfounded', False)
    
    # Return only Counted Crimes
    q = Crime.query.filter(Crime.count != unfounded).all()

    # Category
    # if category != 'all':
    #     q = q.filter(Crime.crimeCat == category)

    # Time Between

    if proj == 'nad':
        result = CrimeLocNAD().dump(q)
    elif proj == 'wgs':
        result = CrimeLocWGS().dump(q)
    return jsonify(result)

# Query Crime by ID
@app.route('/crime/detail')
def crimedetail():
    id = request.args.get('id')
    q = Crime.query.get(id)
    
    result = CrimeDetail().dump(q)
    return jsonify(result)

# Run the App
if __name__ == "__main__":
    app.run(host = '0.0.0.0', debug=True)