FROM python:3.11-slim

# Install PostgreSQL
RUN apt-get update && apt-get install -y \
    postgresql \
    postgresql-contrib \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# CRITICAL: Create the data directory so the volume has a place to land
RUN mkdir -p /var/lib/postgresql/data && chown postgres:postgres /var/lib/postgresql/data

WORKDIR /app
COPY requirements.txt .
RUN pip install flask psycopg2-binary
COPY . .
RUN chmod +x /app/entrypoint.sh

EXPOSE 5000
ENTRYPOINT ["/app/entrypoint.sh"]