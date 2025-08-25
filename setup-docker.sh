#!/bin/bash

echo "🚀 Setting up Strapi Docker Environment"
echo "====================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install docker-compose and try again."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created. You can modify it if needed."
else
    echo "ℹ️  .env file already exists."
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p database/backups
mkdir -p public/uploads

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh

# Build and start containers
echo "🐳 Building and starting Docker containers..."
docker-compose down -v 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "🌐 Access your applications:"
    echo "   • Strapi Admin: http://localhost:1337/admin"
    echo "   • Strapi API: http://localhost:1337/api"
    echo "   • PgAdmin: http://localhost:5050 (admin@strapi.local / admin)"
    echo ""
    echo "📊 To view logs:"
    echo "   docker-compose logs -f strapi"
    echo "   docker-compose logs -f postgres"
    echo ""
    echo "💾 To backup database:"
    echo "   ./scripts/backup-db.sh"
    echo ""
    echo "🛑 To stop services:"
    echo "   docker-compose down"
else
    echo "❌ Some services failed to start. Check logs with:"
    echo "   docker-compose logs"
fi
