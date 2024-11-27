import sqlite3
import csv

# Input files
GTFS_DIR = "GTFS_Realtime"
stops_file = GTFS_DIR + "/stops.txt"
trips_file = GTFS_DIR + "/trips.txt"
stop_times_file = GTFS_DIR + "/stop_times.txt"

# SQLite database file
database_file = "static_data.db"

# Connect to SQLite database
conn = sqlite3.connect(database_file)
cursor = conn.cursor()

# Create tables
cursor.execute("""
CREATE TABLE IF NOT EXISTS stops (
    stop_id TEXT PRIMARY KEY,
    stop_name TEXT,
    latitude REAL,
    longitude REAL
)
""")
cursor.execute("""
CREATE TABLE IF NOT EXISTS trips (
    trip_id TEXT PRIMARY KEY,
    route_id TEXT,
    direction_id INTEGER
)
""")
cursor.execute("""
CREATE TABLE IF NOT EXISTS stop_times (
    trip_id TEXT,
    arrival_time TEXT,
    departure_time TEXT,
    stop_id TEXT,
    stop_sequence INTEGER,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id)
)
""")

# Insert stops
with open(stops_file, "r") as file:
    reader = csv.reader(file)
    next(reader)  # Skip header
    for row in reader:
        if len(row) >= 6:
            cursor.execute("""
            INSERT OR IGNORE INTO stops (stop_id, stop_name, latitude, longitude)
            VALUES (?, ?, ?, ?)
            """, (row[0], row[2], float(row[4]), float(row[5])))

# Insert trips
with open(trips_file, "r") as file:
    reader = csv.reader(file)
    next(reader)  # Skip header
    for row in reader:
        if len(row) >= 6:
            cursor.execute("""
            INSERT OR IGNORE INTO trips (trip_id, route_id, direction_id)
            VALUES (?, ?, ?)
            """, (row[2], row[0], int(row[5])))

# Insert stop_times
with open(stop_times_file, "r") as file:
    reader = csv.reader(file)
    next(reader)  # Skip header
    for row in reader:
        if len(row) >= 5:
            cursor.execute("""
            INSERT INTO stop_times (trip_id, arrival_time, departure_time, stop_id, stop_sequence)
            VALUES (?, ?, ?, ?, ?)
            """, (row[0], row[1], row[2], row[3], int(row[4])))

# Commit and close connection
conn.commit()
conn.close()

print("Static data imported successfully!")
