# Database Backup & Restore Guide

Complete guide for backing up and restoring your Strapi PostgreSQL database.

## 📋 Overview

You have two sets of scripts:

1. **Docker Scripts** (old) - `backup-db.sh`, `restore-db.sh`
2. **Standalone Scripts** (new) - `backup-db-standalone.sh`, `restore-db-standalone.sh`

Use **standalone scripts** for non-Docker deployments (your current setup).

---

## 🔧 Setup & Configuration

### Environment Variables

Create a `.pgpass` file for password-less operations (optional but recommended):

```bash
# Create .pgpass file
echo "localhost:5432:strapi:strapi:your_password" > ~/.pgpass
chmod 600 ~/.pgpass
```

Or export database password:

```bash
export DB_PASSWORD="your_password"
```

### Script Configuration

The scripts use these default values (can be overridden):

```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=strapi
DB_USER=strapi
```

---

## 💾 Backup Operations

### Create a Backup

```bash
# Basic backup
./scripts/backup-db-standalone.sh

# With custom settings
DB_HOST=localhost DB_NAME=strapi DB_USER=strapi ./scripts/backup-db-standalone.sh
```

**What it does:**

- Creates timestamped backup: `strapi_backup_YYYY-MM-DD_HH-MM-SS.dump`
- Saves to: `./database/backups/`
- Uses PostgreSQL custom format (compressed)
- Keeps last 7 backups automatically

### Backup File Location

```
database/
├── backups/
│   ├── strapi_backup_2025-10-15_10-30-00.dump
│   ├── strapi_backup_2025-10-14_10-30-00.dump
│   └── ...
└── migrations/
    └── jonwin_2025-08-25.dump
```

### Manual Backup

```bash
# Custom format (recommended)
pg_dump -h localhost -U strapi -d strapi -Fc -f backup.dump

# Plain SQL format
pg_dump -h localhost -U strapi -d strapi > backup.sql

# Compressed SQL
pg_dump -h localhost -U strapi -d strapi | gzip > backup.sql.gz
```

---

## 🔄 Restore Operations

### Restore from Backup

```bash
# Interactive restore (prompts for backup file)
./scripts/restore-db-standalone.sh

# It will:
# 1. Show available backups
# 2. Ask you to select one
# 3. Confirm before restoring
# 4. Stop Strapi
# 5. Drop and recreate database
# 6. Restore data
# 7. Restart Strapi
```

### Restore Specific Backup

When prompted, enter full path:

```bash
# From migrations
./database/migrations/jonwin_2025-08-25.dump

# From backups
./database/backups/strapi_backup_2025-10-15_10-30-00.dump
```

### Manual Restore

```bash
# Stop Strapi first
pm2 stop strapi

# Custom format dump
pg_restore -h localhost -U strapi -d strapi --clean backup.dump

# Plain SQL
psql -h localhost -U strapi -d strapi < backup.sql

# Compressed SQL
gunzip -c backup.sql.gz | psql -h localhost -U strapi -d strapi

# Restart Strapi
pm2 restart strapi
```

---

## 🖥️ Server Backup & Restore

### On Your Server

Same scripts work on your server:

```bash
# SSH to server
ssh user@your-server

# Navigate to project
cd /home/user/strapi

# Create backup
./scripts/backup-db-standalone.sh

# Restore
./scripts/restore-db-standalone.sh
```

### Download Server Backup to Local

```bash
# From your local machine
scp user@your-server:/home/user/strapi/database/backups/strapi_backup_*.dump ./database/backups/
```

### Upload Local Backup to Server

```bash
# From your local machine
scp ./database/backups/strapi_backup_*.dump user@your-server:/home/user/strapi/database/backups/
```

---

## 📅 Automated Backups

### Setup Cron Job on Server

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /home/user/strapi && ./scripts/backup-db-standalone.sh >> /home/user/logs/backup.log 2>&1

# Add weekly backup on Sunday at 3 AM (keeps separate)
0 3 * * 0 cd /home/user/strapi && ./scripts/backup-db-standalone.sh >> /home/user/logs/backup-weekly.log 2>&1
```

### Backup Rotation Script

Create `scripts/cleanup-old-backups.sh`:

```bash
#!/bin/bash
# Keep only last 30 days of backups
find ./database/backups/ -name "strapi_backup_*.dump" -mtime +30 -delete

# Keep only last 12 weekly backups
ls -t ./database/backups/strapi_backup_*.dump | tail -n +13 | xargs -r rm
```

Add to crontab:

```bash
0 4 * * * cd /home/user/strapi && ./scripts/cleanup-old-backups.sh
```

---

## 🔍 Verify Backup

### Check Backup File

```bash
# Check file format
file database/backups/strapi_backup_*.dump

# List contents without restoring
pg_restore -l database/backups/strapi_backup_*.dump

# Check size
du -h database/backups/strapi_backup_*.dump
```

### Test Restore (Safe)

```bash
# Restore to a test database
createdb strapi_test
pg_restore -d strapi_test database/backups/strapi_backup_*.dump

# Check data
psql -d strapi_test -c "SELECT COUNT(*) FROM events;"

# Drop test database
dropdb strapi_test
```

---

## 🚨 Emergency Recovery

### Quick Recovery Steps

1. **Stop Strapi**

   ```bash
   pm2 stop strapi
   ```

2. **Restore Latest Backup**

   ```bash
   ./scripts/restore-db-standalone.sh
   # Select most recent backup
   ```

3. **Check Restoration**

   ```bash
   psql -U strapi -d strapi -c "SELECT COUNT(*) FROM events;"
   ```

4. **Restart**
   ```bash
   pm2 restart strapi
   pm2 logs strapi
   ```

### If Restore Fails

```bash
# Try manual restore
dropdb -U strapi strapi
createdb -U strapi strapi
pg_restore -U strapi -d strapi --no-acl --no-owner backup.dump

# Check logs
tail -f ~/.pm2/logs/strapi-error.log
```

---

## 📊 Data Verification

### Check Data After Restore

```bash
# Connect to database
psql -U strapi -d strapi

# Check tables
\dt

# Count records
SELECT 'events' as table, COUNT(*) FROM events
UNION ALL SELECT 'partners', COUNT(*) FROM partners
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'files', COUNT(*) FROM files;

# Exit
\q
```

### Compare Backups

```bash
# List tables in backup
pg_restore -l backup1.dump > list1.txt
pg_restore -l backup2.dump > list2.txt
diff list1.txt list2.txt
```

---

## ⚙️ Advanced Usage

### Backup Specific Tables

```bash
# Backup only events table
pg_dump -h localhost -U strapi -d strapi -t events -Fc -f events_backup.dump

# Backup multiple tables
pg_dump -h localhost -U strapi -d strapi -t events -t partners -Fc -f content_backup.dump
```

### Restore Specific Tables

```bash
# Restore only events table
pg_restore -h localhost -U strapi -d strapi -t events events_backup.dump
```

### Backup Schema Only

```bash
# Schema without data
pg_dump -h localhost -U strapi -d strapi --schema-only -Fc -f schema_backup.dump
```

### Backup Data Only

```bash
# Data without schema
pg_dump -h localhost -U strapi -d strapi --data-only -Fc -f data_backup.dump
```

---

## 🛠️ Troubleshooting

### Permission Denied

```bash
# Check PostgreSQL permissions
sudo -u postgres psql -c "\du"

# Grant permissions
sudo -u postgres psql -c "ALTER USER strapi WITH SUPERUSER;"
```

### Connection Refused

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Start if not running
sudo systemctl start postgresql

# Check port
sudo netstat -tlnp | grep 5432
```

### Backup File Corrupted

```bash
# Verify backup integrity
pg_restore -l backup.dump

# If corrupted, restore from older backup
ls -lt database/backups/
./scripts/restore-db-standalone.sh
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Clean old backups
rm database/backups/old_backup_*.dump

# Clean npm cache
npm cache clean --force
```

---

## 📝 Best Practices

### ✅ DO:

- Backup before major changes
- Keep multiple backup copies
- Test restore process regularly
- Store backups off-site
- Automate daily backups
- Monitor backup sizes
- Document restore procedures

### ❌ DON'T:

- Don't store backups only on same server
- Don't skip testing restores
- Don't ignore backup failures
- Don't restore to production without testing
- Don't delete old backups immediately

---

## 📚 Quick Reference

### Backup Commands

```bash
# Local backup
./scripts/backup-db-standalone.sh

# Server backup
ssh user@server './scripts/backup-db-standalone.sh'

# Manual backup
pg_dump -U strapi -d strapi -Fc -f backup.dump
```

### Restore Commands

```bash
# Interactive restore
./scripts/restore-db-standalone.sh

# Manual restore
pg_restore -U strapi -d strapi backup.dump

# From SQL file
psql -U strapi -d strapi < backup.sql
```

### Verification

```bash
# List backups
ls -lh database/backups/

# Check backup
pg_restore -l backup.dump

# Verify data
psql -U strapi -d strapi -c "SELECT COUNT(*) FROM events;"
```

---

**💡 Pro Tip:** Always test your restore process in a non-production environment first!

**🆘 Need Help?** Check the [Troubleshooting](#troubleshooting) section or examine backup logs.
