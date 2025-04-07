#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

print_error() {
    echo -e "${RED}[!] $1${NC}"
}

# Function to create directory with proper permissions
create_directory() {
    local dir="$1"
    local owner="$2"
    local group="$3"
    local mode="$4"
    
    if [ -d "$dir" ]; then
        print_status "Directory already exists: $dir"
        print_status "Updating permissions for: $dir"
        sudo chown "$owner:$group" "$dir"
        sudo chmod "$mode" "$dir"
    else
        print_status "Creating directory: $dir"
        sudo mkdir -p "$dir"
        sudo chown "$owner:$group" "$dir"
        sudo chmod "$mode" "$dir"
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed
package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to check if a service is running
service_running() {
    systemctl is-active --quiet "$1"
}

# Function to install packages
install_packages() {
    print_status "Updating package lists..."
    sudo apt update

    # List of required packages
    packages=(
        curl wget git unzip nginx php8.4-fpm php8.4-mbstring php8.4-xml 
        php8.4-curl php8.4-zip php8.4-gd php8.4-cli php8.4-common 
        php8.4-opcache tor
    )

    # Add database packages based on choice
    if [ "$db_type" == "mysql" ]; then
        packages+=(mysql-server php8.4-mysql)
    else
        packages+=(php8.4-sqlite3)
    fi

    # Add development packages if in development mode
    if [ "$environment" == "development" ]; then
        packages+=(php8.4-xdebug php8.4-dev)
    fi

    # Install only missing packages
    for package in "${packages[@]}"; do
        if package_installed "$package"; then
            print_status "Package already installed: $package"
        else
            print_status "Installing package: $package"
            sudo apt install -y "$package"
        fi
    done

    # Install Node.js and npm if not present
    if ! command_exists node; then
        print_status "Installing Node.js and npm..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
    else
        print_status "Node.js is already installed"
    fi

    # Install Composer if not present
    if ! command_exists composer; then
        print_status "Installing Composer..."
        curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    else
        print_status "Composer is already installed"
    fi
}

# Function to create required directories
create_directories() {
    print_status "Creating required directories..."
    
    # Create Tor hidden service directory
    create_directory "/var/lib/tor/message-board" "debian-tor" "debian-tor" "700"
    
    # Create Nginx directories
    create_directory "/etc/nginx/sites-available" "root" "root" "755"
    create_directory "/etc/nginx/sites-enabled" "root" "root" "755"
    
    # Create web root directory
    create_directory "/usr/share/nginx/message-board" "www-data" "www-data" "755"
    
    # Create essential Laravel directories
    create_directory "/usr/share/nginx/message-board/app" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/bootstrap" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/config" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/database" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/public" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/resources" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/routes" "www-data" "www-data" "755"
    create_directory "/usr/share/nginx/message-board/storage" "www-data" "www-data" "775"
    create_directory "/usr/share/nginx/message-board/vendor" "www-data" "www-data" "755"
    
    # Create writable directories
    create_directory "/usr/share/nginx/message-board/bootstrap/cache" "www-data" "www-data" "775"
    create_directory "/usr/share/nginx/message-board/storage/app" "www-data" "www-data" "775"
    create_directory "/usr/share/nginx/message-board/storage/framework" "www-data" "www-data" "775"
    create_directory "/usr/share/nginx/message-board/storage/logs" "www-data" "www-data" "775"
    create_directory "/usr/share/nginx/message-board/public/build" "www-data" "www-data" "755"
}

# Function to configure MySQL
configure_mysql() {
    print_status "Configuring MySQL..."
    
    # Check if MySQL is already configured
    if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ] && [ -f /root/.my.cnf ]; then
        print_status "MySQL is already configured"
        return
    fi

    # Start MySQL if not running
    if ! service_running mysql; then
        sudo systemctl start mysql
    else
        print_status "MySQL service is already running"
    fi

    # Secure MySQL installation
    print_status "Securing MySQL installation..."
    sudo mysql_secure_installation

    # Create database and user
    print_status "Creating MySQL database and user..."
    read -p "Enter MySQL root password: " mysql_root_password
    read -p "Enter database name [message_board]: " db_name
    db_name=${db_name:-message_board}
    read -p "Enter database user [message_user]: " db_user
    db_user=${db_user:-message_user}
    read -p "Enter database password: " db_password

    mysql -u root -p"$mysql_root_password" <<EOF
CREATE DATABASE IF NOT EXISTS $db_name;
CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
EOF
}

# Function to configure SQLite
configure_sqlite() {
    print_status "Configuring SQLite..."
    
    # Create database directory if it doesn't exist
    sudo mkdir -p /var/www/message-board/database
    
    # Create SQLite database file
    sudo touch /var/www/message-board/database/database.sqlite
    
    # Set proper permissions
    sudo chown -R www-data:www-data /var/www/message-board/database
    sudo chmod 775 /var/www/message-board/database
    sudo chmod 664 /var/www/message-board/database/database.sqlite
    
    # Set database variables for .env file
    db_name="/var/www/message-board/database/database.sqlite"
    db_user=""
    db_password=""
}

# Function to configure PHP-FPM
configure_php_fpm() {
    print_status "Configuring PHP-FPM..."
    
    # Check if PHP-FPM is already configured
    if [ -f /etc/php/8.4/fpm/php.ini.bak ]; then
        print_status "PHP-FPM is already configured"
        return
    fi
    
    # Backup original php.ini
    sudo cp /etc/php/8.4/fpm/php.ini /etc/php/8.4/fpm/php.ini.bak
    
    # Update PHP settings
    sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/8.4/fpm/php.ini
    sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/8.4/fpm/php.ini
    sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/8.4/fpm/php.ini
    sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.4/fpm/php.ini
    
    # Restart PHP-FPM
    sudo systemctl restart php8.4-fpm
}

# Function to configure Nginx
configure_nginx() {
    print_status "Configuring Nginx..."
    
    # Check if Nginx is already configured
    if [ -f /etc/nginx/sites-enabled/message-board.conf ]; then
        print_status "Nginx is already configured for message-board"
        return
    fi
    
    # Create Nginx configuration
    read -p "Enter your domain name [localhost]: " domain
    domain=${domain:-localhost}
    
    # Create Nginx configuration file
    sudo tee /etc/nginx/sites-available/message-board.conf <<EOF
server {
    listen 80;
    server_name $domain;
    root /usr/share/nginx/message-board/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php\$ {
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    # Handle frontend assets
    location /build/ {
        alias /usr/share/nginx/message-board/public/build/;
        try_files \$uri \$uri/ =404;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

    # Create symlink
    print_status "Creating Nginx symlink..."
    sudo ln -sf /etc/nginx/sites-available/message-board.conf /etc/nginx/sites-enabled/message-board.conf
    
    # Remove default site if it exists
    if [ -f /etc/nginx/sites-enabled/default ]; then
        sudo rm -f /etc/nginx/sites-enabled/default
    fi
    
    # Test and restart Nginx
    print_status "Testing Nginx configuration..."
    sudo nginx -t
    sudo systemctl restart nginx
}

# Function to configure Tor
configure_tor() {
    print_status "Configuring Tor..."
    
    # Check if Tor is already configured
    if [ -f /var/lib/tor/message-board/hostname ]; then
        print_status "Tor is already configured for message-board"
        onion_address=$(sudo cat /var/lib/tor/message-board/hostname)
        print_status "Your existing Tor onion address is: $onion_address"
        return
    fi
    
    # Backup original torrc
    sudo cp /etc/tor/torrc /etc/tor/torrc.bak
    
    # Add hidden service configuration
    sudo tee -a /etc/tor/torrc <<EOF
HiddenServiceDir /var/lib/tor/message-board/
HiddenServicePort 80 127.0.0.1:80
EOF
    
    # Restart Tor
    sudo systemctl restart tor
    
    # Wait for onion address to be generated
    print_status "Waiting for Tor to generate onion address..."
    sleep 10
    
    # Display onion address
    onion_address=$(sudo cat /var/lib/tor/message-board/hostname)
    print_status "Your Tor onion address is: $onion_address"
}

# Function to backup database
backup_database() {
    print_status "Creating database backup..."
    local backup_dir="/var/backups/message-board"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Create backup directory if it doesn't exist
    create_directory "$backup_dir" "root" "root" "700"
    
    if [ "$db_type" == "mysql" ]; then
        # Backup MySQL database
        mysqldump -u "$db_user" -p"$db_password" "$db_name" > "$backup_dir/${db_name}_${timestamp}.sql"
        if [ $? -ne 0 ]; then
            print_error "Failed to backup MySQL database"
            return 1
        fi
    else
        # Backup SQLite database
        cp "$db_name" "$backup_dir/database_${timestamp}.sqlite"
        if [ $? -ne 0 ]; then
            print_error "Failed to backup SQLite database"
            return 1
        fi
    fi
    
    print_status "Database backup created successfully"
    return 0
}

# Function to rollback database
rollback_database() {
    print_status "Rolling back database changes..."
    local backup_dir="/var/backups/message-board"
    local latest_backup=$(ls -t "$backup_dir" | head -n1)
    
    if [ -z "$latest_backup" ]; then
        print_error "No backup found to rollback to"
        return 1
    fi
    
    if [ "$db_type" == "mysql" ]; then
        # Rollback MySQL database
        mysql -u "$db_user" -p"$db_password" "$db_name" < "$backup_dir/$latest_backup"
        if [ $? -ne 0 ]; then
            print_error "Failed to rollback MySQL database"
            return 1
        fi
    else
        # Rollback SQLite database
        cp "$backup_dir/$latest_backup" "$db_name"
        if [ $? -ne 0 ]; then
            print_error "Failed to rollback SQLite database"
            return 1
        fi
    fi
    
    print_status "Database rollback completed successfully"
    return 0
}

# Function to handle database setup
handle_database_setup() {
    print_status "Setting up database..."
    
    # Backup existing database
    if ! backup_database; then
        print_warning "Continuing without backup"
    fi
    
    # Create database if it doesn't exist
    if [ "$db_type" == "mysql" ]; then
        mysql -u "$db_user" -p"$db_password" -e "CREATE DATABASE IF NOT EXISTS $db_name;"
        if [ $? -ne 0 ]; then
            print_error "Failed to create MySQL database"
            return 1
        fi
    else
        if [ ! -f "$db_name" ]; then
            touch "$db_name"
            chmod 664 "$db_name"
            if [ $? -ne 0 ]; then
                print_error "Failed to create SQLite database file"
                return 1
            fi
        fi
    fi
    
    # Run migrations
    print_status "Running database migrations..."
    if ! php artisan migrate; then
        print_error "Failed to run migrations"
        if ! rollback_database; then
            print_error "Failed to rollback database"
        fi
        return 1
    fi
    
    # Handle seeders
    if [ "$environment" == "development" ]; then
        read -p "Do you want to run database seeders? (y/n) [y]: " run_seeders
        run_seeders=${run_seeders:-y}
        if [[ $run_seeders =~ ^[Yy]$ ]]; then
            print_status "Running database seeders..."
            if ! php artisan db:seed; then
                print_error "Failed to run seeders"
                if ! rollback_database; then
                    print_error "Failed to rollback database"
                fi
                return 1
            fi
        fi
    else
        print_status "Running essential database seeders..."
        if ! php artisan db:seed --class=DatabaseSeeder; then
            print_error "Failed to run essential seeders"
            if ! rollback_database; then
                print_error "Failed to rollback database"
            fi
            return 1
        fi
    fi
    
    print_status "Database setup completed successfully"
    return 0
}

# Function to install the application
install_application() {
    print_status "Installing the Message Board application..."
    
    # Clone the repository
    git clone https://github.com/yourusername/message-board.git /tmp/message-board
    
    # Move only essential files to web root
    sudo cp -r /tmp/message-board/app /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/bootstrap /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/config /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/database /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/public /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/resources /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/routes /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/storage /usr/share/nginx/message-board/
    sudo cp -r /tmp/message-board/vendor /usr/share/nginx/message-board/
    
    # Copy essential files
    sudo cp /tmp/message-board/.env.example /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/artisan /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/composer.json /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/composer.lock /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/package.json /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/package-lock.json /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/phpunit.xml /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/server.php /usr/share/nginx/message-board/
    sudo cp /tmp/message-board/webpack.mix.js /usr/share/nginx/message-board/
    
    # Clean up
    rm -rf /tmp/message-board
    
    # Install PHP dependencies
    cd /usr/share/nginx/message-board
    if [ "$environment" == "production" ]; then
        composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
    else
        composer install --no-interaction --prefer-dist --optimize-autoloader
    fi
    
    # Install NPM dependencies and build assets
    if [ "$environment" == "production" ]; then
        npm install --production
    else
        npm install
    fi
    npm run build
    
    # Set up environment file
    cp .env.example .env
    php artisan key:generate
    
    # Update .env file with database settings
    if [ "$db_type" == "mysql" ]; then
        sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=mysql/" .env
        sed -i "s/DB_DATABASE=.*/DB_DATABASE=$db_name/" .env
        sed -i "s/DB_USERNAME=.*/DB_USERNAME=$db_user/" .env
        sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$db_password/" .env
    else
        sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=sqlite/" .env
        sed -i "s/DB_DATABASE=.*/DB_DATABASE=$db_name/" .env
    fi
    
    # Set environment
    sed -i "s/APP_ENV=.*/APP_ENV=$environment/" .env
    if [ "$environment" == "production" ]; then
        sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" .env
    else
        sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/" .env
    fi
    
    # Handle database setup
    if ! handle_database_setup; then
        print_error "Database setup failed"
        exit 1
    fi
    
    # Set permissions
    sudo chown -R www-data:www-data /usr/share/nginx/message-board
    sudo chmod -R 775 /usr/share/nginx/message-board/storage
    sudo chmod -R 775 /usr/share/nginx/message-board/bootstrap/cache
    
    # Clear caches
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    # Optimize for production
    if [ "$environment" == "production" ]; then
        php artisan optimize
    fi
}

# Function to configure security settings
configure_security() {
    print_status "Configuring security settings..."
    
    # Configure UFW firewall
    if ! command_exists ufw; then
        print_status "Installing UFW firewall..."
        sudo apt install -y ufw
    fi
    
    # Allow necessary ports
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow ssh
    sudo ufw --force enable
    
    # Install and configure fail2ban
    if ! command_exists fail2ban-client; then
        print_status "Installing fail2ban..."
        sudo apt install -y fail2ban
    fi
    
    # Configure fail2ban for Nginx and SSH
    sudo tee /etc/fail2ban/jail.local <<EOF
[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
    
    sudo systemctl restart fail2ban
    
    # Configure automatic security updates
    sudo tee /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::DevRelease "auto";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF
    
    sudo tee /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
}

# Function to configure monitoring
configure_monitoring() {
    print_status "Configuring monitoring..."
    
    # Install Monit
    if ! command_exists monit; then
        print_status "Installing Monit..."
        sudo apt install -y monit
    fi
    
    # Configure Monit
    sudo tee /etc/monit/monitrc <<EOF
set daemon 60
set logfile /var/log/monit.log
set idfile /var/lib/monit/id
set statefile /var/lib/monit/state

set eventqueue
    basedir /var/lib/monit/events
    slots 100

set mailserver localhost
set alert root@localhost

set httpd port 2812 and
    use address localhost
    allow localhost

check process nginx with pidfile /var/run/nginx.pid
    start program = "/etc/init.d/nginx start"
    stop program = "/etc/init.d/nginx stop"
    if failed host localhost port 80 protocol http then restart
    if cpu > 60% for 2 cycles then alert
    if cpu > 80% for 5 cycles then restart

check process php-fpm with pidfile /var/run/php/php8.4-fpm.pid
    start program = "/etc/init.d/php8.4-fpm start"
    stop program = "/etc/init.d/php8.4-fpm stop"
    if failed unixsocket /var/run/php/php8.4-fpm.sock then restart
    if cpu > 60% for 2 cycles then alert
    if cpu > 80% for 5 cycles then restart

check process mysql with pidfile /var/run/mysqld/mysqld.pid
    start program = "/etc/init.d/mysql start"
    stop program = "/etc/init.d/mysql stop"
    if failed host localhost port 3306 then restart
    if cpu > 60% for 2 cycles then alert
    if cpu > 80% for 5 cycles then restart
EOF
    
    sudo systemctl restart monit
    
    # Configure log rotation
    sudo tee /etc/logrotate.d/message-board <<EOF
/usr/share/nginx/message-board/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 \`cat /var/run/nginx.pid\`
        fi
    endscript
}
EOF
}

# Function to configure performance optimizations
configure_performance() {
    print_status "Configuring performance optimizations..."
    
    # Install Redis
    if ! command_exists redis-cli; then
        print_status "Installing Redis..."
        sudo apt install -y redis-server
    fi
    
    # Configure Redis
    sudo sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf
    sudo systemctl restart redis-server
    
    # Configure PHP OPcache
    sudo tee /etc/php/8.4/fpm/conf.d/10-opcache.ini <<EOF
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF
    
    # Configure Nginx performance
    sudo tee /etc/nginx/conf.d/performance.conf <<EOF
client_max_body_size 64M;
client_body_buffer_size 128k;
client_header_buffer_size 1k;
large_client_header_buffers 4 4k;
sendfile on;
tcp_nopush on;
tcp_nodelay on;
keepalive_timeout 65;
types_hash_max_size 2048;
server_tokens off;
gzip on;
gzip_disable "msie6";
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
EOF
    
    # Configure MySQL performance
    if [ "$db_type" == "mysql" ]; then
        sudo tee /etc/mysql/conf.d/message-board.cnf <<EOF
[mysqld]
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
query_cache_type = 1
query_cache_size = 32M
max_connections = 100
EOF
        
        sudo systemctl restart mysql
    fi
}

# Function to show installation summary
show_summary() {
    print_status "Installation Summary:"
    print_status "Environment: $environment"
    print_status "Database Type: $db_type"
    if [ "$db_type" == "mysql" ]; then
        print_status "Database Name: $db_name"
        print_status "Database User: $db_user"
    else
        print_status "SQLite Database: $db_name"
    fi
    print_status "Domain: $domain"
    print_status "Tor Address: $onion_address"
    print_status "Security Features:"
    print_status "- UFW Firewall configured"
    print_status "- Fail2ban installed and configured"
    print_status "- Automatic security updates enabled"
    print_status "Monitoring:"
    print_status "- Monit installed and configured"
    print_status "- Log rotation configured"
    print_status "Performance Optimizations:"
    print_status "- Redis installed and configured"
    print_status "- PHP OPcache configured"
    print_status "- Nginx performance tuned"
    if [ "$db_type" == "mysql" ]; then
        print_status "- MySQL performance optimized"
    fi
    
    read -p "Do you want to proceed with the installation? (y/n) [y]: " proceed
    proceed=${proceed:-y}
    if [[ ! $proceed =~ ^[Yy]$ ]]; then
        print_error "Installation aborted by user"
        exit 1
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check PHP
    print_status "Checking PHP..."
    php -v
    if [ $? -ne 0 ]; then
        print_error "PHP verification failed"
        return 1
    fi
    
    # Check Nginx
    print_status "Checking Nginx..."
    nginx -t
    if [ $? -ne 0 ]; then
        print_error "Nginx verification failed"
        return 1
    fi
    
    # Check database
    print_status "Checking database..."
    if [ "$db_type" == "mysql" ]; then
        mysql -u "$db_user" -p"$db_password" -e "SELECT 1;" "$db_name"
        if [ $? -ne 0 ]; then
            print_error "MySQL verification failed"
            return 1
        fi
    else
        if [ ! -f "$db_name" ]; then
            print_error "SQLite database file not found"
            return 1
        fi
    fi
    
    # Check Laravel
    print_status "Checking Laravel..."
    cd /usr/share/nginx/message-board
    php artisan --version
    if [ $? -ne 0 ]; then
        print_error "Laravel verification failed"
        return 1
    fi
    
    # Check services
    print_status "Checking services..."
    services=("nginx" "php8.4-fpm" "redis-server")
    if [ "$db_type" == "mysql" ]; then
        services+=("mysql")
    fi
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            print_error "Service $service is not running"
            return 1
        fi
    done
    
    # Check Tor
    print_status "Checking Tor..."
    if ! systemctl is-active --quiet tor; then
        print_error "Tor service is not running"
        return 1
    fi
    
    # Check security features if enabled
    if [ "$enable_security" == "y" ]; then
        print_status "Checking security features..."
        if ! systemctl is-active --quiet ufw; then
            print_error "UFW is not running"
            return 1
        fi
        
        if ! systemctl is-active --quiet fail2ban; then
            print_error "Fail2ban is not running"
            return 1
        fi
    fi
    
    # Check monitoring if enabled
    if [ "$enable_monitoring" == "y" ]; then
        print_status "Checking monitoring..."
        if ! systemctl is-active --quiet monit; then
            print_error "Monit is not running"
            return 1
        fi
    fi
    
    print_status "All verifications passed successfully!"
    return 0
}

# Function to test application
test_application() {
    print_status "Testing application..."
    
    # Test database connection
    print_status "Testing database connection..."
    cd /usr/share/nginx/message-board
    php artisan tinker --execute="DB::connection()->getPdo()"
    if [ $? -ne 0 ]; then
        print_error "Database connection test failed"
        return 1
    fi
    
    # Test routes
    print_status "Testing routes..."
    php artisan route:list
    if [ $? -ne 0 ]; then
        print_error "Route test failed"
        return 1
    fi
    
    # Test cache
    print_status "Testing cache..."
    php artisan cache:clear
    if [ $? -ne 0 ]; then
        print_error "Cache test failed"
        return 1
    fi
    
    # Test storage
    print_status "Testing storage..."
    php artisan storage:link
    if [ $? -ne 0 ]; then
        print_error "Storage test failed"
        return 1
    fi
    
    print_status "All application tests passed successfully!"
    return 0
}

# Main installation process
main() {
    print_status "Starting installation process..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run this script as root or with sudo"
        exit 1
    fi
    
    # Ask for environment
    while true; do
        read -p "Which environment would you like to set up? (development/production) [production]: " environment
        environment=${environment:-production}
        if [ "$environment" == "production" ] || [ "$environment" == "development" ]; then
            break
        else
            print_error "Please enter either 'development' or 'production'"
        fi
    done
    
    # Ask for database type
    while true; do
        read -p "Which database would you like to use? (mysql/sqlite) [mysql]: " db_type
        db_type=${db_type:-mysql}
        if [ "$db_type" == "mysql" ] || [ "$db_type" == "sqlite" ]; then
            break
        else
            print_error "Please enter either 'mysql' or 'sqlite'"
        fi
    done
    
    # Ask about security features
    read -p "Do you want to enable security features? (y/n) [y]: " enable_security
    enable_security=${enable_security:-y}
    
    # Ask about monitoring
    read -p "Do you want to enable monitoring? (y/n) [y]: " enable_monitoring
    enable_monitoring=${enable_monitoring:-y}
    
    # Show installation summary
    show_summary
    
    # Create directories
    create_directories
    
    # Install packages
    install_packages
    
    # Configure security if enabled
    if [ "$enable_security" == "y" ]; then
        configure_security
    fi
    
    # Configure monitoring if enabled
    if [ "$enable_monitoring" == "y" ]; then
        configure_monitoring
    fi
    
    # Configure performance
    configure_performance
    
    # Configure database
    if [ "$db_type" == "mysql" ]; then
        configure_mysql
    else
        configure_sqlite
    fi
    
    # Configure services
    configure_php_fpm
    configure_nginx
    configure_tor
    install_application
    
    # Verify installation
    if ! verify_installation; then
        print_error "Installation verification failed"
        exit 1
    fi
    
    # Test application
    if ! test_application; then
        print_error "Application testing failed"
        exit 1
    fi
    
    print_status "Installation completed successfully!"
    print_status "You can access your application at:"
    print_status "Regular URL: http://$domain"
    print_status "Tor URL: http://$onion_address"
    print_status "Default admin credentials:"
    print_status "Email: admin@example.com"
    print_status "Password: password123"
    
    if [ "$environment" == "development" ]; then
        print_status "Development environment is set up with:"
        print_status "- Debug mode enabled"
        print_status "- Development dependencies installed"
        print_status "- Xdebug installed for debugging"
    else
        print_status "Production environment is set up with:"
        print_status "- Debug mode disabled"
        print_status "- Production optimizations enabled"
        print_status "- Development dependencies excluded"
    fi
    
    if [ "$enable_security" == "y" ]; then
        print_status "Security features enabled:"
        print_status "- UFW Firewall configured"
        print_status "- Fail2ban installed and configured"
        print_status "- Automatic security updates enabled"
    fi
    
    if [ "$enable_monitoring" == "y" ]; then
        print_status "Monitoring enabled:"
        print_status "- Monit installed and configured"
        print_status "- Log rotation configured"
    fi
    
    print_status "Performance optimizations:"
    print_status "- Redis installed and configured"
    print_status "- PHP OPcache configured"
    print_status "- Nginx performance tuned"
    if [ "$db_type" == "mysql" ]; then
        print_status "- MySQL performance optimized"
    fi
    
    print_status "Verification and testing completed successfully!"
}

# Run the main function
main 