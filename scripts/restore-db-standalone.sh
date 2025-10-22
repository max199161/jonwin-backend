#!/bin/bash

# Database Restore Script (Non-Docker Version)
# Restores a PostgreSQL backup without Docker

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Starting database restoration process...${NC}"

# Configuration - update these to match your setup
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-strapi}"
DB_USER="${DB_USER:-strapi}"
MIGRATIONS_DIR="./database/migrations"
BACKUPS_DIR="./database/backups"

# Function to list available backup files
list_backups() {
    echo -e "\n${BLUE}📂 Available backup files:${NC}"
    echo -e "${BLUE}From migrations:${NC}"
    ls -lh "$MIGRATIONS_DIR"/*.dump 2>/dev/null | awk '{print $9, "("$5")"}'
    echo -e "\n${BLUE}From backups:${NC}"
    ls -lht "$BACKUPS_DIR"/*.dump 2>/dev/null | head -5 | awk '{print $9, "("$5")"}'
}

# List available backups
list_backups

# Ask user to select a backup file
echo -e "\n${YELLOW}Please enter the path to the backup file:${NC}"
echo -e "${YELLOW}(or press Enter to use default: $MIGRATIONS_DIR/jonwin_2025-08-25.dump)${NC}"
read -r BACKUP_FILE

# Use default if no input
if [ -z "$BACKUP_FILE" ]; then
    BACKUP_FILE="$MIGRATIONS_DIR/jonwin_2025-08-25.dump"
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Using backup file: $BACKUP_FILE${NC}"
echo -e "${YELLOW}📊 File size: $(du -h "$BACKUP_FILE" | cut -f1)${NC}"

# Check if PostgreSQL is accessible
if ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to PostgreSQL database.${NC}"
    echo -e "${YELLOW}Please check your database connection settings.${NC}"
    exit 1
fi

# Warning
echo -e "\n${RED}⚠️  WARNING: This will REPLACE all data in the '$DB_NAME' database!${NC}"
echo -e "${YELLOW}Are you sure you want to continue? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Restoration cancelled.${NC}"
    exit 0
fi

# Stop Strapi if it's running with PM2
if command -v pm2 > /dev/null 2>&1; then
    echo -e "${YELLOW}⏸️  Stopping Strapi...${NC}"
    pm2 stop strapi 2>/dev/null || true
    sleep 3
fi

# Terminate existing connections
echo -e "${YELLOW}🔌 Terminating existing connections...${NC}"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "
    SELECT pg_terminate_backend(pg_stat_activity.pid)
    FROM pg_stat_activity
    WHERE pg_stat_activity.datname = '$DB_NAME'
    AND pid <> pg_backend_pid();
" 2>/dev/null

sleep 2

# Drop and recreate database
echo -e "${YELLOW}🗑️  Dropping and recreating database...${NC}"
PGPASSWORD=$DB_PASSWORD dropdb -h $DB_HOST -p $DB_PORT -U $DB_USER --if-exists $DB_NAME
PGPASSWORD=$DB_PASSWORD createdb -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to recreate database${NC}"
    exit 1
fi

# Detect backup file format
FILE_TYPE=$(file "$BACKUP_FILE")
echo -e "${YELLOW}🔍 Backup file type: $FILE_TYPE${NC}"

# Restore database
echo -e "${YELLOW}📥 Restoring database...${NC}"
RESTORE_SUCCESS=false

# Method 1: Try pg_restore (for custom format dumps)
if [[ $FILE_TYPE == *"PostgreSQL custom database dump"* ]]; then
    echo -e "${YELLOW}Using pg_restore...${NC}"
    PGPASSWORD=$DB_PASSWORD pg_restore \
        -h $DB_HOST \
        -p $DB_PORT \
        -U $DB_USER \
        -d $DB_NAME \
        -v \
        --no-acl \
        --no-owner \
        "$BACKUP_FILE" 2>&1 | grep -v "^$"
    
    if [ ${PIPESTATUS[0]} -eq 0 ] || [ ${PIPESTATUS[0]} -eq 1 ]; then
        # Exit code 1 is acceptable (warnings only)
        RESTORE_SUCCESS=true
        echo -e "${GREEN}✅ Restored using pg_restore${NC}"
    fi
fi

# Method 2: Try psql (for plain text dumps)
if [ "$RESTORE_SUCCESS" = false ]; then
    if [[ $FILE_TYPE == *"ASCII text"* ]] || [[ $FILE_TYPE == *"SQL"* ]]; then
        echo -e "${YELLOW}Using psql...${NC}"
        PGPASSWORD=$DB_PASSWORD psql \
            -h $DB_HOST \
            -p $DB_PORT \
            -U $DB_USER \
            -d $DB_NAME \
            -f "$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            RESTORE_SUCCESS=true
            echo -e "${GREEN}✅ Restored using psql${NC}"
        fi
    fi
fi

# Method 3: Try gunzip + psql (for compressed dumps)
if [ "$RESTORE_SUCCESS" = false ]; then
    if [[ $FILE_TYPE == *"gzip"* ]]; then
        echo -e "${YELLOW}Using gunzip + psql...${NC}"
        gunzip -c "$BACKUP_FILE" | PGPASSWORD=$DB_PASSWORD psql \
            -h $DB_HOST \
            -p $DB_PORT \
            -U $DB_USER \
            -d $DB_NAME
        
        if [ $? -eq 0 ]; then
            RESTORE_SUCCESS=true
            echo -e "${GREEN}✅ Restored using gunzip + psql${NC}"
        fi
    fi
fi

# Restart Strapi if PM2 is available
if command -v pm2 > /dev/null 2>&1; then
    echo -e "${YELLOW}🚀 Restarting Strapi...${NC}"
    pm2 restart strapi 2>/dev/null || pm2 start npm --name "strapi" -- start
    sleep 5
fi

# Check restoration success
if [ "$RESTORE_SUCCESS" = true ]; then
    echo -e "\n${GREEN}✅ Database restored successfully!${NC}"
    
    # Check table count
    echo -e "${YELLOW}📊 Checking restored data...${NC}"
    TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';")
    echo -e "${GREEN}Number of tables: $(echo $TABLE_COUNT | xargs)${NC}"
    
    # Show some data counts
    echo -e "\n${YELLOW}📈 Data counts:${NC}"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT 'events' as table_name, COUNT(*) as count FROM events
        UNION ALL SELECT 'partners', COUNT(*) FROM partners
        UNION ALL SELECT 'stores', COUNT(*) FROM stores
        UNION ALL SELECT 'files', COUNT(*) FROM files;
    " 2>/dev/null || echo "Some tables may not exist yet"
    
    echo -e "\n${GREEN}🎉 Restoration complete!${NC}"
    echo -e "${GREEN}You can now access Strapi at http://localhost:1337${NC}"
else
    echo -e "${RED}❌ Database restoration failed${NC}"
    echo -e "${YELLOW}Please check the backup file format and try again.${NC}"
    exit 1
fi
