import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from mysql.connector import pooling
from datetime import datetime

app = Flask(__name__)
CORS(app)

dbconfig = {
    'host':     'localhost',
    'user':     'root',
    'password': 'Fa03mi062',
    'database': 'signaldata'
}

pool = pooling.MySQLConnectionPool(
    pool_name='mypool',
    pool_size=5,
    **dbconfig
)

@app.route('/data', methods=['GET', 'POST'])
def data():
    if request.method == 'POST':
        body = request.get_json(force=True)
        bpm = body.get('bpm', 0)
        ekg = body.get('ekg', body.get('ekg_value', []))
        emg = body.get('emg', body.get('emg_value', []))

        conn = pool.get_connection()
        cursor = conn.cursor()
        sql = "INSERT INTO measurement (bpm, ekg, emg) VALUES (%s, %s, %s)"
        cursor.execute(sql, (
            bpm,
            json.dumps(ekg),
            json.dumps(emg),
        ))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'status': 'ok'}), 201

    else:
        conn = pool.get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT *, NOW() AS ts FROM measurement ORDER BY id DESC LIMIT 1")
        row = cursor.fetchone()
        cursor.close()
        conn.close()

        if row:
            row['ekg'] = json.loads(row['ekg'])
            row['emg'] = json.loads(row['emg'])
            row['timestamp'] = row['ts'].isoformat()
            del row['ts']
            return jsonify(row)
        else:
            return jsonify({
                'bpm': 0,
                'ekg': [],
                'emg': [],
                'timestamp': datetime.utcnow().isoformat()
            })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=False)