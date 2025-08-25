#!/bin/bash

# Backup current database
echo "Creating backup of current database..."
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).dump"

pg_dump -h localhost -p 5432 -U strapi -d strapi -f "database/backups/$BACKUP_FILE" --format=custom

if [ $? -eq 0 ]; then
    echo "Backup created successfully: database/backups/$BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi
