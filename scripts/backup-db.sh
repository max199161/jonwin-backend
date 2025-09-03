#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DB_CONTAINER="strapi-strapiDB-1"
DB_NAME="strapi"
DB_USER="strapi"
BACKUP_DIR="./database/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/strapi_backup_$TIMESTAMP.dump"

echo -e "${YELLOW}💾 Starting database backup process...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if container is running
if ! docker ps | grep -q $DB_CONTAINER; then
    echo -e "${RED}❌ Database container is not running. Please start the services first.${NC}"
    exit 1
fi

# Create database backup
echo -e "${YELLOW}📤 Creating backup: $BACKUP_FILE${NC}"
docker exec $DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME -Fc > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database backup created successfully: $BACKUP_FILE${NC}"
    echo -e "${GREEN}📁 Backup size: $(du -h "$BACKUP_FILE" | cut -f1)${NC}"
else
    echo -e "${RED}❌ Database backup failed${NC}"
    exit 1
fi
