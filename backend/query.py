import psycopg2

conn = psycopg2.connect('postgresql://bonded_user:4ywNZ9l62b2c05iZ0ac5GjMUqAs4xDdd@dpg-d85ufct7vvec73elao10-a.oregon-postgres.render.com/bonded')
cur = conn.cursor()

cur.execute("SELECT id, start_date, expected_end_date, status, duration_label, created_at, ended_at FROM separations WHERE id IN (38, 39);")
seps = cur.fetchall()
for sep in seps:
    print("Sep:", sep)

cur.close()
conn.close()
