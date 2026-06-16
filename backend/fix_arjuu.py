import psycopg2
from datetime import date, timedelta

conn = psycopg2.connect('postgresql://bonded_user:4ywNZ9l62b2c05iZ0ac5GjMUqAs4xDdd@dpg-d85ufct7vvec73elao10-a.oregon-postgres.render.com/bonded')
cur = conn.cursor()

today = date(2026, 6, 14) # Current UTC date
end_date = today + timedelta(days=15)

# Revert separation 39 back to Day 1
cur.execute("UPDATE separations SET start_date = %s, expected_end_date = %s, status = 'active' WHERE id = 39;", (today, end_date))
conn.commit()

cur.execute("SELECT id, start_date, expected_end_date, status, duration_label FROM separations WHERE id = 39;")
print(cur.fetchone())

cur.close()
conn.close()
