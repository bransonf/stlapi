# Define the Models for SQLAlchemy

# Crime Table
class Crime(db.model):
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
class CrimeLoc(ma.schema):
    class Meta:
        fields = ('id','crimeCat','wgsX','wgsY')

# Crime Details
class CrimeDetail(ma.schema):
    class Meta:
        fields = ('id', 'dataOccur','crimeCat','description','wgsX','wgsY')

#class CSB(db.model):
