import json
from flask import Flask, request, jsonify # Import necessary modules from Flask
from flask_cors import CORS # Import CORS to handle cross-origin requests
from mysql.connector import pooling # Import MySQL connection pooling
from datetime import datetime # Import datetime for timestamp handling

app = Flask(__name__) # Initialize Flask application
CORS(app) # Enable CORS for the Flask app

dbconfig = {
    'host':     'xxx', # Replace with your actual host
    'user':     'xxx', # Replace with your actual username
    'password': 'xxx', # Replace with your actual password
    'database': 'xxx' # Replace with your actual database name
}

pool = pooling.MySQLConnectionPool(
    pool_name='xxx', # Replace with your desired pool name
    pool_size=5, # Define the pool size, size set to 5 for better performance
    **dbconfig
)

@app.route('/data', methods=['GET', 'POST']) # Define the /data endpoint to handle both GET and POST requests
def data():
    if request.method == 'POST': # Handle POST request to insert new measurement data
        body = request.get_json(force=True)
        bpm = body.get('bpm', 0)
        ekg = body.get('ekg', body.get('ekg_value', []))
        emg = body.get('emg', body.get('emg_value', []))

        conn = pool.get_connection() # Get a connection from the pool
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
        conn = pool.get_connection()  # Handle GET request to retrieve the latest measurement data
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