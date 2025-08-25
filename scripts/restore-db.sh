#!/bin/bash

# Set environment variables
export PGPASSWORD=strapi

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h postgres -p 5432 -U strapi; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is ready!"

# Check if database already has data (excluding system tables)
EXISTING_TABLES=$(psql -h postgres -U strapi -d strapi -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" 2>/dev/null | xargs)

echo "Found $EXISTING_TABLES existing tables in public schema"

if [ "$EXISTING_TABLES" -gt 5 ]; then
    echo "Database already contains $EXISTING_TABLES tables. Skipping restoration."
    echo "To force restoration, delete the volume: docker-compose down -v"
    exit 0
fi

echo "Restoring database from dump..."

# Check if dump file exists
if [ ! -f "/docker-entrypoint-initdb.d/jonwin_2025-08-25.dump" ]; then
    echo "Dump file not found!"
    exit 1
fi

# Drop existing database and recreate (to ensure clean state)
echo "Recreating database for clean restore..."
psql -h postgres -U strapi -d postgres -c "DROP DATABASE IF EXISTS strapi;"
psql -h postgres -U strapi -d postgres -c "CREATE DATABASE strapi OWNER strapi;"

# Restore the database dump with verbose output and data
echo "Restoring database structure and data..."
pg_restore -h postgres -U strapi -d strapi \
    --verbose \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    --format=custom \
    /docker-entrypoint-initdb.d/jonwin_2025-08-25.dump

RESTORE_EXIT_CODE=$?

if [ $RESTORE_EXIT_CODE -eq 0 ] || [ $RESTORE_EXIT_CODE -eq 1 ]; then
    # Exit code 1 is often just warnings, check if data was actually restored
    DATA_COUNT=$(psql -h postgres -U strapi -d strapi -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" 2>/dev/null | xargs)
    
    if [ "$DATA_COUNT" -gt 5 ]; then
        echo "Database restoration completed successfully!"
        echo "Restored $DATA_COUNT tables"
        
        # Show some sample data to verify
        echo "Verifying data restoration..."
        psql -h postgres -U strapi -d strapi -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public' LIMIT 10;"
    else
        echo "Database restoration may have failed - only $DATA_COUNT tables found"
        exit 1
    fi
else
    echo "Database restoration failed with exit code: $RESTORE_EXIT_CODE"
    exit 1
fi
