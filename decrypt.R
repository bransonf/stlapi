#!/usr/local/bin/RScript

# Requires getPass, sodium, cyphr, jsonlite
# Run from dir /flask

source('https://bransonf.com/scripts/encryption.R')
pwd = Sys.getenv('pass')
a = decrypt_yaml('../creds2.yml.encrypted', pwd)
gsub('\\[|\\]','',jsonlite::toJSON(a))

