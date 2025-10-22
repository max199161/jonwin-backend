#!/bin/bash

# Strapi Update Deployment Script
# This script prepares your Strapi project for updating a running server
# IMPORTANT: Excludes uploads folder to preserve production data

set -e

echo "================================================"
echo "Strapi Update Package Creator"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if build directory exists
if [ ! -d "build" ]; then
    echo -e "${YELLOW}Building admin panel...${NC}"
    npm run build
    echo -e "${GREEN}✓ Admin panel built${NC}"
else
    echo -e "${YELLOW}Build directory exists. Rebuild? (y/n)${NC}"
    read -r rebuild
    if [ "$rebuild" = "y" ]; then
        npm run build
        echo -e "${GREEN}✓ Admin panel rebuilt${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}Creating update package (without uploads)...${NC}"
echo -e "${BLUE}ℹ Server uploads will be preserved${NC}"

# Create tar.gz excluding unnecessary files AND uploads
tar -czf strapi-update.tar.gz \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='.env' \
    --exclude='.tmp' \
    --exclude='database/backups/*' \
    --exclude='public/uploads/*' \
    --exclude='docker-compose*.yml' \
    --exclude='Dockerfile' \
    --exclude='setup-docker.sh' \
    --exclude='setup-production.sh' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='strapi-update.tar.gz' \
    --exclude='strapi-deploy.tar.gz' \
    .

echo -e "${GREEN}✓ Update package created: strapi-update.tar.gz${NC}"
echo ""

# Get file size
size=$(du -h strapi-update.tar.gz | cut -f1)
echo "Package size: $size"
echo ""

echo "================================================"
echo "Deploy to Running Server:"
echo "================================================"
echo ""
echo "1. Copy update package to server:"
echo "   scp strapi-update.tar.gz user@your-server:/home/user/strapi/"
echo ""
echo "2. On your server, extract and update:"
echo ""
echo "   cd /home/user/strapi"
echo "   tar -xzf strapi-update.tar.gz"
echo "   rm -rf node_modules"
echo "   npm install"
echo "   pm2 restart strapi"
echo ""
echo "3. Check logs:"
echo "   pm2 logs strapi"
echo ""
echo -e "${GREEN}Note: Uploads and .env on server are preserved!${NC}"
echo ""
echo "If npm install fails:"
echo "   rm -f package-lock.json"
echo "   npm cache clean --force"
echo "   npm install"
echo ""
echo -e "${GREEN}✓ Uploads and database on server will NOT be affected!${NC}"
echo ""
