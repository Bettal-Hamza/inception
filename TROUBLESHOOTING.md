# Troubleshooting Guide for Inception Project

## 🔴 502 Bad Gateway Error

### Cause:
NGINX can't communicate with WordPress/PHP-FPM container.

### Solutions:

#### 1. Check All Containers Are Running
```bash
docker ps
```
You should see 3 containers running: nginx, wordpress, mariadb

#### 2. Check Container Logs
```bash
# Check WordPress logs
docker-compose -f srcs/docker-compose.yml logs wordpress

# Check NGINX logs
docker-compose -f srcs/docker-compose.yml logs nginx

# Check MariaDB logs
docker-compose -f srcs/docker-compose.yml logs mariadb
```

#### 3. Verify WordPress Is Ready
```bash
# Enter wordpress container
docker exec -it $(docker ps -qf "name=wordpress") sh

# Check if php-fpm is running
ps aux | grep php-fpm

# Check if WordPress files exist
ls -la /var/www/html/

# Exit container
exit
```

#### 4. Test Network Connectivity
```bash
# From nginx container, ping wordpress
docker exec $(docker ps -qf "name=nginx") ping -c 3 wordpress

# Check if port 9000 is open on wordpress
docker exec $(docker ps -qf "name=nginx") nc -zv wordpress 9000
```

#### 5. Verify Data Directories Exist
```bash
ls -la /home/hbettal/data/wordpress/
ls -la /home/hbettal/data/mariadb/
```

If directories are empty or don't exist:
```bash
sudo mkdir -p /home/hbettal/data/wordpress /home/hbettal/data/mariadb
sudo chown -R $USER:$USER /home/hbettal/data
```

#### 6. Restart Services in Order
```bash
cd /path/to/inception

# Stop everything
make down

# Clean volumes (if needed)
make fclean

# Rebuild and start
make
```

---

## 🔴 Database Connection Errors

### WordPress can't connect to MariaDB

#### Check MariaDB is running:
```bash
docker exec -it $(docker ps -qf "name=mariadb") sh
mysql -u wpuser -pSecureDBPass123
SHOW DATABASES;
exit
```

#### Verify .env variables are correct:
```bash
cat srcs/.env | grep MYSQL
```

#### Check network connectivity:
```bash
docker exec $(docker ps -qf "name=wordpress") ping -c 3 mariadb
```

---

## 🔴 Permission Denied Errors

### Data directories permission issues:
```bash
# Fix ownership
sudo chown -R $USER:$USER /home/hbettal/data

# Fix permissions
sudo chmod -R 755 /home/hbettal/data
```

---

## 🔴 Port Already in Use

### Port 443 is already bound:
```bash
# Check what's using port 443
sudo lsof -i :443

# Or
sudo netstat -tulpn | grep 443

# Stop the service or kill the process
sudo systemctl stop <service-name>
```

---

## 🔴 SSL Certificate Errors

### Browser shows security warning:
This is **NORMAL** for self-signed certificates!
- Click "Advanced"
- Click "Proceed to hbettal.42.fr"

### Verify SSL is working:
```bash
openssl s_client -connect hbettal.42.fr:443 -showcerts < /dev/null
```

---

## 🔴 WordPress Installation Issues

### WordPress doesn't install automatically:

#### Check WordPress container logs:
```bash
docker-compose -f srcs/docker-compose.yml logs wordpress
```

#### Manually trigger WordPress installation:
```bash
# Enter wordpress container
docker exec -it $(docker ps -qf "name=wordpress") sh

# Check if database is accessible
mysql -h mariadb -u wpuser -pSecureDBPass123 -e "SHOW DATABASES;"

# Manually run wp-cli commands
cd /var/www/html
wp core install --url="https://hbettal.42.fr" --title="Inception" \
  --admin_user="hbettal" --admin_password="SecureAdminPass123" \
  --admin_email="hbettal@student.42.fr" --skip-email --allow-root

# Create second user
wp user create hbettal_user hbettal_user@student.42.fr \
  --role=author --user_pass="SecureUserPass123" --allow-root

exit
```

---

## 🔴 Volume Mount Issues

### Error: "Invalid mount config"

#### Ensure data directories exist BEFORE starting containers:
```bash
sudo mkdir -p /home/hbettal/data/wordpress
sudo mkdir -p /home/hbettal/data/mariadb
```

#### Or use the Makefile (it creates them automatically):
```bash
make
```

---

## 🔴 Docker Compose Not Found

### Error: "docker-compose: command not found"

#### Install docker-compose:
```bash
# For Debian/Ubuntu
sudo apt-get install docker-compose-plugin

# OR standalone version
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

---

## 🔴 Cannot Access https://hbettal.42.fr

### Domain not resolving:

#### 1. Check /etc/hosts file:
```bash
cat /etc/hosts | grep hbettal
```

If not there, add it:
```bash
echo "127.0.0.1 hbettal.42.fr" | sudo tee -a /etc/hosts
```

#### 2. Test with IP directly:
```bash
curl -k https://127.0.0.1
```

#### 3. Test DNS resolution:
```bash
ping hbettal.42.fr
```

---

## 🧪 Complete Health Check

Run these commands to verify everything:

```bash
#!/bin/bash

echo "=== Checking Containers ==="
docker ps

echo -e "\n=== Checking Networks ==="
docker network ls | grep inception

echo -e "\n=== Checking Volumes ==="
docker volume ls | grep inception

echo -e "\n=== Checking Data Directories ==="
ls -la /home/hbettal/data/

echo -e "\n=== Testing NGINX ==="
curl -k -I https://hbettal.42.fr

echo -e "\n=== Checking Container Logs (last 10 lines) ==="
echo "--- NGINX ---"
docker-compose -f srcs/docker-compose.yml logs --tail=10 nginx

echo -e "\n--- WordPress ---"
docker-compose -f srcs/docker-compose.yml logs --tail=10 wordpress

echo -e "\n--- MariaDB ---"
docker-compose -f srcs/docker-compose.yml logs --tail=10 mariadb

echo -e "\n=== Testing Database Connection ==="
docker exec $(docker ps -qf "name=mariadb") mysql -u wpuser -pSecureDBPass123 -e "SHOW DATABASES;"

echo -e "\n=== Checking WordPress Users ==="
docker exec $(docker ps -qf "name=wordpress") wp user list --allow-root

echo -e "\n✅ Health check complete!"
```

Save this as `healthcheck.sh` and run:
```bash
chmod +x healthcheck.sh
./healthcheck.sh
```

---

## 🆘 Nuclear Option - Complete Reset

If nothing works, start fresh:

```bash
# 1. Stop and remove everything
docker-compose -f srcs/docker-compose.yml down -v

# 2. Remove all Docker resources
docker system prune -af --volumes

# 3. Delete data directories
sudo rm -rf /home/hbettal/data/*

# 4. Recreate directories
sudo mkdir -p /home/hbettal/data/wordpress /home/hbettal/data/mariadb
sudo chown -R $USER:$USER /home/hbettal/data

# 5. Rebuild from scratch
make re
```

---

## 📞 Quick Diagnostics

```bash
# Check if all services respond
docker-compose -f srcs/docker-compose.yml ps

# Check service health
docker inspect $(docker ps -qf "name=nginx") | grep -i health
docker inspect $(docker ps -qf "name=wordpress") | grep -i health
docker inspect $(docker ps -qf "name=mariadb") | grep -i health

# Real-time logs (follow mode)
docker-compose -f srcs/docker-compose.yml logs -f

# Check resource usage
docker stats
```
