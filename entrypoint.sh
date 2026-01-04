#!/bin/bash
set -e

# Find Postgres binaries
PG_PATH=$(find /usr/lib/postgresql/ -name initdb | head -n 1 | xargs dirname)

# NEW: Point Postgres to a SUBFOLDER inside the mount
# This avoids trying to 'chown' the mount point itself
export PGDATA="/var/lib/postgresql/data/db_files"

# Create the subfolder if it doesn't exist
if [ ! -d "$PGDATA" ]; then
    echo "LOG: Creating subfolder $PGDATA"
    mkdir -p "$PGDATA"
    chown -R postgres:postgres /var/lib/postgresql/data
fi

# Initialize if empty
if [ ! -d "$PGDATA/base" ]; then
    echo "LOG: Initializing DB in $PGDATA"
    su postgres -c "$PG_PATH/initdb -D $PGDATA"
fi

# Start Postgres
echo "LOG: Starting PostgreSQL..."
su postgres -c "$PG_PATH/pg_ctl -D $PGDATA -l /tmp/postgres.log start"

# Wait for Postgres to start
echo "LOG: Waiting for PostgreSQL to become available..."
while ! su postgres -c "$PG_PATH/pg_isready"; do
    sleep 1
done
echo "LOG: PostgreSQL is ready."


# Setup DB/User (using the 'app_user' and 'mydb' from before)
su postgres -c "$PG_PATH/psql --command \"CREATE USER app_user WITH SUPERUSER PASSWORD 'password';\"" || true
su postgres -c "$PG_PATH/createdb -O app_user mydb" || true
su postgres -c "$PG_PATH/psql -d mydb -f /app/schema.sql"

echo "LOG: Starting Flask App..."
python3 /app/app.py