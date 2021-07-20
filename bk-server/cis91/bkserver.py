import json 
import datetime
import subprocess 

from flask import Flask, request 

app = Flask(__name__)

backup_script = """
tar -cvf /tmp/backup-{datecode}.tar.gz {source}
gsutil -q cp /tmp/backup-{datecode}.tar.gz gs://{bucket}
rm /tmp/backup-{datecode}.tar.gz
"""

@app.route('/', methods=['GET', 'POST'])
def index():
    return json.dumps("Hello World")

@app.route('/backup', methods=['POST'])
def backup():
    data = json.loads(request.data.decode('utf-8'))
    datecode = round(datetime.datetime.now().timestamp())
    resp = subprocess.run(backup_script.format(
            datecode=datecode,
            source=data['source'],
            bucket=data['target']), 
        shell=True, capture_output=True, encoding='utf-8')
    return json.dumps({
        'exit': resp.returncode,
        'stdout': resp.stdout,
        'stderr': resp.stderr,
    })
