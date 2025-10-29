# Memory Exhausted Error - Fixed!

## The Problem:
```
PHP Fatal error: Allowed memory size of 134217728 bytes exhausted
```

WP-CLI was running out of memory (128MB limit) while trying to download and extract WordPress.

## The Fix Applied:

1. **Increased PHP memory limit to 256MB** in php.ini
2. **Added fallback download method** using curl if WP-CLI fails
3. **More efficient extraction** with tar

## On Your VM - Apply The Fix:

```bash
# 1. Stop containers
sudo docker-compose -f srcs/docker-compose.yml down

# 2. Clean old data
sudo rm -rf /home/hbettal/data/wordpress/*
sudo rm -rf /home/hbettal/data/mariadb/*

# 3. Rebuild WordPress container (forces rebuild)
sudo docker-compose -f srcs/docker-compose.yml build --no-cache wordpress

# 4. Start everything
sudo docker-compose -f srcs/docker-compose.yml up -d

# 5. Watch the logs
sudo docker-compose -f srcs/docker-compose.yml logs -f wordpress
```

## What You Should See Now:

```
wordpress-1  | Waiting for database wordpress...
wordpress-1  | Downloading WordPress...
wordpress-1  | Success: WordPress downloaded.
wordpress-1  | Creating wp-config.php...
wordpress-1  | Success: Generated 'wp-config.php' file.
wordpress-1  | Installing WordPress...
wordpress-1  | Success: WordPress installed successfully.
wordpress-1  | Creating additional WordPress user...
wordpress-1  | Success: Created user 'hbettal_user'.
```

OR if WP-CLI still fails:

```
wordpress-1  | Downloading WordPress...
wordpress-1  | WP-CLI failed, downloading with curl...
wordpress-1  | Creating wp-config.php...
wordpress-1  | Success: Generated 'wp-config.php' file.
```

## Verify WordPress Files:

```bash
# Check files are there
sudo docker exec $(sudo docker ps -qf "name=wordpress") ls -la /var/www/html/

# Should see:
# index.php
# wp-config.php
# wp-admin/
# wp-content/
# wp-includes/
# etc.
```

## Test The Site:

```bash
# Test with curl
curl -k https://hbettal.42.fr

# Or in browser
# https://hbettal.42.fr
```

## If Still Having Issues:

### Check PHP memory limit was applied:
```bash
sudo docker exec $(sudo docker ps -qf "name=wordpress") php -i | grep memory_limit
# Should show: memory_limit => 256M => 256M
```

### Manual WordPress download (last resort):
```bash
# Enter container
sudo docker exec -it $(sudo docker ps -qf "name=wordpress") sh

# Download manually
cd /var/www/html
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm latest.tar.gz
ls -la

# Exit and restart container
exit
sudo docker-compose -f srcs/docker-compose.yml restart wordpress
```

## Quick Commands:

```bash
# Full restart
sudo docker-compose -f srcs/docker-compose.yml restart

# Check all containers
sudo docker ps

# Follow all logs
sudo docker-compose -f srcs/docker-compose.yml logs -f

# Check WordPress container only
sudo docker-compose -f srcs/docker-compose.yml logs wordpress
```
