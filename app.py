import os
from flask import Flask, jsonify, request, send_from_directory
import psycopg2

app = Flask(__name__, static_folder="static")


def get_db_connection():
    return psycopg2.connect(
        dbname=os.environ.get("POSTGRES_DB", "mydb"),
        user=os.environ.get("POSTGRES_USER", "app_user"),
        password=os.environ.get("POSTGRES_PASSWORD", "password"),
        host=os.environ.get("POSTGRES_HOST", "localhost"),
    )


@app.route("/")
def index():
    return send_from_directory("static", "index.html")


@app.route("/api/guestbook", methods=["GET"])
def get_entries():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT name, message FROM guestbook ORDER BY id DESC;")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify([{"name": r[0], "message": r[1]} for r in rows])


@app.route("/api/guestbook", methods=["POST"])
def add_entry():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO guestbook (name, message) VALUES (%s, %s)",
        (data["name"], data["message"]),
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
