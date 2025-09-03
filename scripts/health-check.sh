#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Checking Docker services health...${NC}"

# Check if docker-compose services are running
services=("strapi-strapiDB-1" "strapi-strapi-1")

for service in "${services[@]}"; do
    if docker ps --filter "name=${service}" --format "table {{.Names}}\t{{.Status}}" | grep -q "Up"; then
        echo -e "${GREEN}✅ ${service} is running${NC}"
    else
        echo -e "${RED}❌ ${service} is not running${NC}"
    fi
done

echo ""
echo -e "${YELLOW}📊 Container Status:${NC}"
docker-compose ps

echo ""
echo -e "${YELLOW}🌐 Service URLs:${NC}"
echo -e "Strapi Admin: ${GREEN}http://localhost:1337/admin${NC}"
echo -e "Strapi API: ${GREEN}http://localhost:1337/api${NC}"
echo -e "Database Admin (Adminer): ${GREEN}http://localhost:9090${NC}"
echo -e "Database Direct: ${GREEN}localhost:5432${NC}"
