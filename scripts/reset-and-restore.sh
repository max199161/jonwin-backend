#!/bin/bash

echo "🔄 Resetting and Restoring Database"
echo "=================================="

# Stop all services
echo "Stopping all services..."
docker-compose down

# Remove only the database volume (keep uploads)
echo "Removing database volume..."
docker volume rm strapi_postgres_data 2>/dev/null || true

# Rebuild and start services
echo "Rebuilding and starting services..."
docker-compose up --build -d

echo ""
echo "⏳ Waiting for database restoration to complete..."
sleep 15

# Check restore status
echo "🔍 Checking restoration status..."
docker-compose logs db-restore

echo ""
echo "📊 Checking database content..."
docker-compose exec postgres psql -U strapi -d strapi -c "SELECT schemaname, tablename, n_tup_ins as row_count FROM pg_stat_user_tables WHERE schemaname = 'public' LIMIT 10;"

echo ""
echo "✅ Database reset and restore completed!"
echo "🌐 You can now access Strapi at: http://localhost:1337"
