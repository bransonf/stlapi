# Attempt to Decrypt In Python
import base64
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

from cryptography.fernet import Fernet

password= b"password" 
kdf = PBKDF2HMAC(
    algorithm=hashes.SHA256(),
    length=32,
    salt=b"salt",
    iterations=100000,
    backend=default_backend()
)
key = base64.urlsafe_b64encode(kdf.derive(password))

with open('../creds.yml', 'rb') as f:
    data = f.read()

enc = Fernet(key).encrypt(data)

with open('creds.py.enc', 'wb') as f:
    f.write(enc)
