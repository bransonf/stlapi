# Crime Queries

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


# define functions for interacting with database (Crime table)

# Get Coordinates of Crimes
def coords(con, start, end=None, category='all', proj='wgs', unfounded=False):
    cur = con.cursor()

    # Build and Execute Query
    if proj == 'wgs':
        qry = 'SELECT "wgsX", "wgsY", "crimeCat" FROM crime'
    elif proj == 'nad':
        qry = 'SELECT "nadX", "nadY", "crimeCat" FROM crime'

    # Unfounded
    if not unfounded:
        qry = qry + ' WHERE "count" = true' 
    else:
        qry = qry + ' WHERE "count" = false'

    # Category Handling
    if category != 'all':
        qry = qry + ' AND "crimeCat" = ' + '\'' + category + '\''

    # Date Range
    if end == None:
        end = start
    
    qry = qry + ' AND "dateOccur" BETWEEN date \'' + start + '\' AND date \'' + end + '\';' 

    cur.execute(qry)

    q = cur.fetchall()
    cur.close()
    return(list(q))

# Get Details Based on ID of Crime
def detail(con, id=None):
    cur = con.cursor()

    # Build and Execute Query
    qry = 'SELECT * FROM crime WHERE "id" = ' + id
    cur.execute(qry)

    q = cur.fetchall()
    cur.close()
    return(list(q))

# Get Summary Based on Region/Date
def summary(con, start, end, category, unfounded=False, neighborhood=None, district=None):
    cur = con.cursor()
    cur.execute()

    q = cur.fetchall()
    cur.close()
    return(list(q))