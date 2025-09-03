#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Starting database restoration process...${NC}"

# Configuration
DB_CONTAINER="strapi-strapiDB-1"
DB_NAME="strapi"
DB_USER="strapi"
BACKUP_FILE="/docker-entrypoint-initdb.d/jonwin_2025-08-25.dump"

# Check if container is running
if ! docker ps | grep -q $DB_CONTAINER; then
    echo -e "${RED}❌ Database container is not running. Please start the services first with: docker-compose up -d${NC}"
    exit 1
fi

# Wait for database to be ready
echo -e "${YELLOW}⏳ Waiting for database to be ready...${NC}"
docker exec $DB_CONTAINER bash -c "
    until pg_isready -U $DB_USER -d $DB_NAME; do
        echo 'Waiting for PostgreSQL to start...'
        sleep 2
    done
"

# Check if backup file exists
if ! docker exec $DB_CONTAINER test -f "$BACKUP_FILE"; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    echo -e "${YELLOW}Make sure your backup file 'jonwin_2025-08-25.dump' is in the database/migrations/ directory${NC}"
    exit 1
fi

# Check backup file format
echo -e "${YELLOW}🔍 Checking backup file format...${NC}"
BACKUP_FORMAT=$(docker exec $DB_CONTAINER file "$BACKUP_FILE")
echo "Backup file info: $BACKUP_FORMAT"

# Stop Strapi to disconnect from database
echo -e "${YELLOW}⏸️  Stopping Strapi to disconnect from database...${NC}"
docker-compose stop strapi

# Wait a moment for connections to close
sleep 5

# Terminate any remaining connections
echo -e "${YELLOW}🔌 Terminating existing connections...${NC}"
docker exec $DB_CONTAINER bash -c "
    psql -U $DB_USER -d postgres -c \"
        SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = '$DB_NAME'
        AND pid <> pg_backend_pid();
    \"
"

# Drop existing database and recreate
echo -e "${YELLOW}🗑️  Dropping existing database and recreating...${NC}"
docker exec $DB_CONTAINER bash -c "
    dropdb -U $DB_USER --if-exists $DB_NAME
    createdb -U $DB_USER $DB_NAME
"

# Try different restoration methods based on file format
echo -e "${YELLOW}📥 Restoring database from backup...${NC}"

# Method 1: Try pg_restore (for custom format dumps)
echo -e "${YELLOW}Attempting pg_restore...${NC}"
if docker exec $DB_CONTAINER pg_restore -U $DB_USER -d $DB_NAME -v --clean --no-acl --no-owner "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Database restored successfully using pg_restore${NC}"
    RESTORE_SUCCESS=true
else
    echo -e "${YELLOW}pg_restore failed, trying psql...${NC}"
    
    # Method 2: Try psql (for plain text dumps)
    if docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -f "$BACKUP_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ Database restored successfully using psql${NC}"
        RESTORE_SUCCESS=true
    else
        echo -e "${YELLOW}psql failed, trying gunzip + psql...${NC}"
        
        # Method 3: Try gunzip + psql (for compressed dumps)
        if docker exec $DB_CONTAINER bash -c "gunzip -c '$BACKUP_FILE' | psql -U $DB_USER -d $DB_NAME" 2>/dev/null; then
            echo -e "${GREEN}✅ Database restored successfully using gunzip + psql${NC}"
            RESTORE_SUCCESS=true
        else
            echo -e "${RED}❌ All restoration methods failed${NC}"
            echo -e "${YELLOW}The backup file format may not be compatible with this PostgreSQL version.${NC}"
            echo -e "${YELLOW}Please check the backup file format or provide a different backup.${NC}"
            RESTORE_SUCCESS=false
        fi
    fi
fi

# Restart Strapi
echo -e "${YELLOW}🚀 Restarting Strapi...${NC}"
docker-compose start strapi

# Wait for Strapi to start
sleep 10

if [ "$RESTORE_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Database restored successfully from jonwin_2025-08-25.dump${NC}"
    echo -e "${GREEN}🎉 You can now access your Strapi application at http://localhost:1337${NC}"
    
    # Check table count
    echo -e "${YELLOW}📊 Checking restored data...${NC}"
    TABLE_COUNT=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';")
    echo -e "${GREEN}Number of tables restored: $TABLE_COUNT${NC}"
else
    echo -e "${RED}❌ Database restoration failed${NC}"
    exit 1
fi
