# Decrypt a Yaml File

from os import environ
import subprocess
import json

# Do this by using an R Script for Now
# Assumes `export pass=****`
def cred():
    pwd = environ.get('pass')
    cmd = 'export pass=' + pwd + '&&' + '../decrypt.R'

    creds = subprocess.check_output(cmd, shell=True)

    jcred = json.loads(creds)
    return jcred
