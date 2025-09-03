#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Jowin Strapi Docker Setup${NC}"
echo -e "${BLUE}=============================${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose is not installed. Please install docker-compose and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"
echo -e "${GREEN}✅ docker-compose is available${NC}"

# Make scripts executable
echo -e "${YELLOW}🔧 Setting up executable permissions for scripts...${NC}"
chmod +x scripts/*.sh

# Generate random secrets for production
echo -e "${YELLOW}🔐 Generating secure secrets...${NC}"

# Generate random strings for secrets
APP_KEYS=$(openssl rand -hex 32)
API_TOKEN_SALT=$(openssl rand -hex 32)
ADMIN_JWT_SECRET=$(openssl rand -hex 32)
TRANSFER_TOKEN_SALT=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)

# Update .env.docker with generated secrets
sed -i.backup "s/your-app-keys-here-change-this-in-production/$APP_KEYS/g" .env.docker
sed -i.backup "s/your-api-token-salt-here-change-this-in-production/$API_TOKEN_SALT/g" .env.docker
sed -i.backup "s/your-admin-jwt-secret-here-change-this-in-production/$ADMIN_JWT_SECRET/g" .env.docker
sed -i.backup "s/your-transfer-token-salt-here-change-this-in-production/$TRANSFER_TOKEN_SALT/g" .env.docker
sed -i.backup "s/your-jwt-secret-here-change-this-in-production/$JWT_SECRET/g" .env.docker

echo -e "${GREEN}✅ Secrets generated and updated in .env.docker${NC}"

# Build and start the services
echo -e "${YELLOW}🏗️  Building Docker images...${NC}"
docker-compose build

echo -e "${YELLOW}🚀 Starting services...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 30

# Run health check
echo -e "${YELLOW}🔍 Running health check...${NC}"
./scripts/health-check.sh

echo ""
echo -e "${BLUE}🎉 Setup complete!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "1. Restore your database: ${GREEN}./scripts/restore-db.sh${NC}"
echo -e "2. Access Strapi admin: ${GREEN}http://localhost:1337/admin${NC}"
echo -e "3. Access Adminer (DB admin): ${GREEN}http://localhost:9090${NC}"
echo ""
echo -e "${YELLOW}📋 Available commands:${NC}"
echo -e "• Start services: ${GREEN}npm run docker:start${NC}"
echo -e "• Stop services: ${GREEN}npm run docker:stop${NC}"
echo -e "• View logs: ${GREEN}npm run docker:logs${NC}"
echo -e "• Health check: ${GREEN}npm run docker:health${NC}"
echo -e "• Backup database: ${GREEN}npm run docker:backup${NC}"
echo -e "• Clean up: ${GREEN}npm run docker:clean${NC}"
