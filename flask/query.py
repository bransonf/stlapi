# Testing SQL Queries from Python

import yaml
import psycopg2
from flask import jsonify

with open(r'../creds.yml') as file:
    creds = yaml.safe_load(file)

dbcon = psycopg2.connect(host = creds['host'],
                        database = creds['database'],
                        user = creds['username'],
                        password = creds['password'])

def range(con, start=0, end=0):
    cur = con.cursor()
    cur.execute("""SELECT "wgsX", "wgsY"
    FROM crime
    WHERE "dateOccur" BETWEEN
    date '2019-11-01' AND date '2019-11-10';""")
    rows = cur.fetchall()
    json = list(rows)
    cur.close()
    return json

print(range(dbcon))