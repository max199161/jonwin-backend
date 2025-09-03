#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Manual Database Restoration Tool${NC}"
echo -e "${BLUE}=====================================${NC}"

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

echo -e "${YELLOW}🔍 Analyzing backup file...${NC}"

# Check file type
FILE_INFO=$(docker exec $DB_CONTAINER file "$BACKUP_FILE")
echo "File info: $FILE_INFO"

# Check first few bytes
HEADER=$(docker exec $DB_CONTAINER head -c 20 "$BACKUP_FILE" | od -c)
echo "File header: $HEADER"

# Check if it's a PostgreSQL custom format dump
if docker exec $DB_CONTAINER bash -c "head -c 5 '$BACKUP_FILE' | grep -q 'PGDMP'"; then
    echo -e "${GREEN}✅ Detected PostgreSQL custom format dump${NC}"
    DUMP_TYPE="custom"
elif docker exec $DB_CONTAINER bash -c "head -1 '$BACKUP_FILE' | grep -q '^--'"; then
    echo -e "${GREEN}✅ Detected SQL text dump${NC}"
    DUMP_TYPE="sql"
elif docker exec $DB_CONTAINER bash -c "file '$BACKUP_FILE' | grep -q 'gzip'"; then
    echo -e "${GREEN}✅ Detected compressed dump${NC}"
    DUMP_TYPE="compressed"
else
    echo -e "${YELLOW}⚠️ Unknown dump format${NC}"
    DUMP_TYPE="unknown"
fi

echo ""
echo -e "${YELLOW}Select restoration method:${NC}"
echo "1. Auto-detect and restore"
echo "2. Force pg_restore (custom format)"
echo "3. Force psql (SQL text)"
echo "4. Force gunzip + psql (compressed)"
echo "5. Convert dump format"
echo "6. Exit"

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo -e "${YELLOW}🔄 Auto-detecting and restoring...${NC}"
        ./scripts/restore-db.sh
        ;;
    2)
        echo -e "${YELLOW}🔄 Using pg_restore...${NC}"
        docker-compose stop strapi
        sleep 3
        docker exec $DB_CONTAINER bash -c "
            psql -U $DB_USER -d postgres -c \"
                SELECT pg_terminate_backend(pg_stat_activity.pid)
                FROM pg_stat_activity
                WHERE pg_stat_activity.datname = '$DB_NAME'
                AND pid <> pg_backend_pid();
            \"
            dropdb -U $DB_USER --if-exists $DB_NAME
            createdb -U $DB_USER $DB_NAME
            pg_restore -U $DB_USER -d $DB_NAME -v --clean --no-acl --no-owner $BACKUP_FILE
        "
        docker-compose start strapi
        ;;
    3)
        echo -e "${YELLOW}🔄 Using psql...${NC}"
        docker-compose stop strapi
        sleep 3
        docker exec $DB_CONTAINER bash -c "
            psql -U $DB_USER -d postgres -c \"
                SELECT pg_terminate_backend(pg_stat_activity.pid)
                FROM pg_stat_activity
                WHERE pg_stat_activity.datname = '$DB_NAME'
                AND pid <> pg_backend_pid();
            \"
            dropdb -U $DB_USER --if-exists $DB_NAME
            createdb -U $DB_USER $DB_NAME
            psql -U $DB_USER -d $DB_NAME -f $BACKUP_FILE
        "
        docker-compose start strapi
        ;;
    4)
        echo -e "${YELLOW}🔄 Using gunzip + psql...${NC}"
        docker-compose stop strapi
        sleep 3
        docker exec $DB_CONTAINER bash -c "
            psql -U $DB_USER -d postgres -c \"
                SELECT pg_terminate_backend(pg_stat_activity.pid)
                FROM pg_stat_activity
                WHERE pg_stat_activity.datname = '$DB_NAME'
                AND pid <> pg_backend_pid();
            \"
            dropdb -U $DB_USER --if-exists $DB_NAME
            createdb -U $DB_USER $DB_NAME
            gunzip -c $BACKUP_FILE | psql -U $DB_USER -d $DB_NAME
        "
        docker-compose start strapi
        ;;
    5)
        echo -e "${YELLOW}🔄 Converting dump format...${NC}"
        echo "Available conversions:"
        echo "a. Convert to SQL text format"
        echo "b. Create new custom format dump"
        read -p "Enter choice (a/b): " conv_choice
        
        case $conv_choice in
            a)
                echo -e "${YELLOW}Converting to SQL text format...${NC}"
                docker exec $DB_CONTAINER bash -c "
                    pg_restore -f /tmp/converted.sql --clean --no-acl --no-owner $BACKUP_FILE 2>/dev/null || 
                    gunzip -c $BACKUP_FILE > /tmp/converted.sql 2>/dev/null ||
                    cp $BACKUP_FILE /tmp/converted.sql
                "
                echo -e "${GREEN}Converted file saved as /tmp/converted.sql in container${NC}"
                ;;
            b)
                echo -e "${YELLOW}Creating new custom format dump...${NC}"
                docker exec $DB_CONTAINER bash -c "
                    # First try to restore to a temp database
                    createdb -U $DB_USER temp_restore_db
                    psql -U $DB_USER -d temp_restore_db -f $BACKUP_FILE 2>/dev/null ||
                    gunzip -c $BACKUP_FILE | psql -U $DB_USER -d temp_restore_db 2>/dev/null
                    
                    # Create new custom format dump
                    pg_dump -U $DB_USER -d temp_restore_db -Fc > /tmp/converted.dump
                    
                    # Clean up
                    dropdb -U $DB_USER temp_restore_db
                "
                echo -e "${GREEN}Converted file saved as /tmp/converted.dump in container${NC}"
                ;;
        esac
        ;;
    6)
        echo -e "${BLUE}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}📊 Checking restoration results...${NC}"
TABLE_COUNT=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null)
if [ ! -z "$TABLE_COUNT" ]; then
    echo -e "${GREEN}Number of tables: $TABLE_COUNT${NC}"
    
    # Show sample tables
    echo -e "${YELLOW}Sample tables:${NC}"
    docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' LIMIT 5;" 2>/dev/null
else
    echo -e "${RED}Could not verify restoration${NC}"
fi
