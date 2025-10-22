#!/bin/bash

# Database Backup Script (Non-Docker Version)
# Creates a PostgreSQL backup without Docker

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}💾 Starting database backup process...${NC}"

# Configuration - update these to match your setup
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-strapi}"
DB_USER="${DB_USER:-strapi}"
BACKUP_DIR="./database/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/strapi_backup_$TIMESTAMP.dump"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if PostgreSQL is accessible
if ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to PostgreSQL database.${NC}"
    echo -e "${YELLOW}Please check your database connection settings.${NC}"
    exit 1
fi

# Create database backup
echo -e "${YELLOW}📤 Creating backup: $BACKUP_FILE${NC}"
echo -e "${YELLOW}Database: $DB_NAME on $DB_HOST:$DB_PORT${NC}"

# Use pg_dump with custom format for better compression and flexibility
PGPASSWORD=$DB_PASSWORD pg_dump \
    -h $DB_HOST \
    -p $DB_PORT \
    -U $DB_USER \
    -d $DB_NAME \
    -Fc \
    -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database backup created successfully!${NC}"
    echo -e "${GREEN}📁 Backup file: $BACKUP_FILE${NC}"
    echo -e "${GREEN}📊 Backup size: $(du -h "$BACKUP_FILE" | cut -f1)${NC}"
    
    # Show recent backups
    echo -e "\n${YELLOW}📂 Recent backups:${NC}"
    ls -lh "$BACKUP_DIR" | tail -5
    
    # Optional: Keep only last 7 backups
    echo -e "\n${YELLOW}🗑️  Cleaning old backups (keeping last 7)...${NC}"
    ls -t "$BACKUP_DIR"/strapi_backup_*.dump | tail -n +8 | xargs -r rm
    
    echo -e "${GREEN}✅ Backup process complete!${NC}"
else
    echo -e "${RED}❌ Database backup failed${NC}"
    exit 1
fi
