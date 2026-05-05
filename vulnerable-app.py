import os
import sqlite3
import subprocess
import shlex
from flask import Flask, request, escape

app = Flask(__name__)

# FIX 1: Credentials z env variables
DB_PASSWORD = os.environ.get("DB_PASSWORD")
API_KEY = os.environ.get("API_KEY")

# FIX 2: Parameterized queries
@app.route("/user")
def get_user():
    username = request.args.get("name")
    conn = sqlite3.connect("app.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE name = ?", (username,))
    return str(cursor.fetchall())

# FIX 3: Whitelist + no shell
@app.route("/ping")
def ping():
    host = request.args.get("host")
    # Walidacja input
    if not host or not host.replace(".", "").isalnum():
        return "Invalid host", 400
    result = subprocess.run(
        ["ping", "-c", "1", host],
        capture_output=True, text=True, timeout=5
    )
    return result.stdout

# FIX 4: Escape output
@app.route("/greet")
def greet():
    name = request.args.get("name", "")
    safe_name = escape(name)
    return f"<h1>Hello {safe_name}</h1>"

if __name__ == "__main__":
    # FIX 7: Debug off, bind to localhost
    app.run(debug=False, host="127.0.0.1")
