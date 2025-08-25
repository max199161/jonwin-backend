#!/bin/bash

echo "🏥 Docker Environment Health Check"
echo "================================="

# Check Docker status
echo "🐳 Checking Docker services..."
docker-compose ps

echo ""
echo "📊 Container resource usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
echo "💾 Volume usage:"
docker system df

echo ""
echo "🌐 Testing application endpoints..."

# Test Strapi health
if curl -f -s http://localhost:1337/_health > /dev/null; then
    echo "✅ Strapi is responding"
else
    echo "❌ Strapi is not responding"
fi

# Test database connection
if docker-compose exec -T postgres pg_isready -U strapi > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
else
    echo "❌ PostgreSQL is not ready"
fi

echo ""
echo "📋 Recent logs (last 10 lines):"
echo "--- Strapi ---"
docker-compose logs --tail=5 strapi
echo "--- PostgreSQL ---"
docker-compose logs --tail=5 postgres
