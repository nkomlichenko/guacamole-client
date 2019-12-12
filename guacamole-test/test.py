import jwt
import requests
from datetime import datetime, timedelta

payload = {
    'GUAC_ID': 'connection_id',
    'guac.hostname': '109.168.97.222',
    'guac.protocol': "rdp",
    'guac.port': '3389',
    'guac.username': 'demo2',
    'guac.password': 'D3m02014*Test',
    'exp': datetime.utcnow() + timedelta(seconds=3600)
}


jwtToken = jwt.encode(payload, 'secret', algorithm='HS512')

resp = requests.post('http://localhost:8080/guacamole/api/tokens', data={'token': jwtToken})

test = resp