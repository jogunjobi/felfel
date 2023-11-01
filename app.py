from flask import Flask
import redis
import os
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

requests = Counter('app_requests', 'Total Request Count')

@app.route('/')
def index():
    username = os.environ['REDIS_USERNAME']
    password = os.environ['REDIS_PASSWORD']
    host = os.environ['REDIS_HOST']
    port = os.environ['REDIS_PORT']
    db = os.environ['REDIS_DB']

    client = redis.Redis(username=username, password=password, host=host, port=port, db=db)
    key = 'HIT_COUNT'

    count = int(client.get(key)) or 0
    response = f'Hello FELFEL. The count is: {count}'
    client.set(key, count + 1)
    requests.inc()
    return response


@app.route('/metrics')
def metrics():
  return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

app.run(host='0.0.0.0', port=8080)