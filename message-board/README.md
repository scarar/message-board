# Message Board Application - Complete Setup Guide

## Table of Contents
1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation Guide](#installation-guide)
4. [Database Setup](#database-setup)
5. [Configuration](#configuration)
6. [Build Process](#build-process)
7. [Web Server Setup](#web-server-setup)
8. [Features](#features)
9. [Troubleshooting](#troubleshooting)
10. [Support](#support)

## Introduction

Welcome to the Message Board Application! This is a modern web application built with Laravel that allows users to:
- Create and manage messages
- Embed YouTube videos in messages
- View message timestamps
- Register and authenticate securely

This guide will walk you through the complete setup process, from installation to configuration.

## System Requirements

### Essential Requirements
- PHP 8.1 or higher
- Composer (PHP package manager)
- Node.js and NPM
- Web server (Apache/Nginx)
- Database (MySQL or SQLite)

### Recommended Development Environment
- Local development server (XAMPP, MAMP, or Laravel Valet)
- Code editor (VS Code, PHPStorm, etc.)
- Git for version control

## Installation Guide

### Automated Installation (Recommended)
We provide an automated installation script that handles everything for you. This is the easiest way to get started.

1. Download the installation script:
   ```bash
   wget https://raw.githubusercontent.com/yourusername/message-board/main/install.sh
   ```

2. Make it executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the script as root:
   ```bash
   sudo ./install.sh
   ```

The script will:
- Install all required packages (Nginx, MySQL, PHP8.4-FPM, Tor, etc.)
- Configure MySQL with secure defaults
- Set up PHP-FPM with optimal settings
- Configure Nginx for your domain
- Set up Tor hidden service
- Install and configure the message board application
- Set proper file permissions
- Import the database schema
- Provide you with both regular and Tor URLs

The script is interactive and will:
- Ask for your MySQL root password
- Let you choose database name and user
- Allow you to set your domain name
- Show you your Tor onion address
- Display the final URLs and admin credentials

### Manual Installation
If you prefer to install manually, follow these steps:

### Step 1: Clone the Repository
```bash
git clone https://github.com/yourusername/message-board.git
cd message-board
```

### Step 2: Install PHP Dependencies
```bash
composer install
```
This will install all required PHP packages including:
- Laravel framework
- Laravel Breeze (authentication)
- Other necessary dependencies

### Step 3: Install Frontend Dependencies
```bash
npm install
npm run dev
```
This installs and compiles:
- Bootstrap CSS framework
- JavaScript dependencies
- Frontend assets

### Step 4: Environment Setup
1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Generate application key:
   ```bash
   php artisan key:generate
   ```

3. Update environment variables (see Configuration section)

## Database Setup

### MySQL Setup (Recommended for Production)

#### Prerequisites
1. MySQL Server installed and running
2. MySQL user with appropriate permissions
3. MySQL command-line client or GUI tool

#### Setup Steps
1. Import the schema file - this will:
   - Create the database if it doesn't exist
   - Create all necessary tables
   - Set up the required indexes
   - Insert sample data
   ```bash
   mysql -u root -p < database/schema.sql
   ```

2. Update `.env` file:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=message_board
   DB_USERNAME=root
   DB_PASSWORD=your_password
   ```

### SQLite Setup (Recommended for Development)

#### Prerequisites
1. PHP with SQLite extension enabled
2. Write permissions in project directory

#### Setup Steps
1. Create database file:
   ```bash
   touch database/database.sqlite
   ```

2. Update `.env` file:
   ```env
   DB_CONNECTION=sqlite
   DB_DATABASE=/absolute/path/to/database.sqlite
   ```

3. Run migrations:
   ```bash
   php artisan migrate
   ```

## Configuration

### Environment Variables
Update these key settings in your `.env` file:

```env
# Application Settings
APP_NAME=MessageBoard
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database Settings (choose one)
# MySQL
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=message_board
DB_USERNAME=root
DB_PASSWORD=your_password

# OR SQLite
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/database.sqlite

# Mail Settings (for password reset)
MAIL_MAILER=smtp
MAIL_HOST=your-smtp-host
MAIL_PORT=587
MAIL_USERNAME=your-email
MAIL_PASSWORD=your-password
MAIL_FROM_ADDRESS=your-email
MAIL_FROM_NAME="${APP_NAME}"

# Message Board Settings
MESSAGE_PAGINATION=10
MESSAGE_PREVIEW_LENGTH=200
YOUTUBE_EMBED_WIDTH=560
YOUTUBE_EMBED_HEIGHT=315
```

### Sample Data
The application includes sample data:
- Two test users:
  - Email: john@example.com, Password: password123
  - Email: jane@example.com, Password: password123
- Three sample messages (two with YouTube videos)

## Build Process

### Development Build
For local development, run:
```bash
npm install
npm run dev
```
This will:
- Install all frontend dependencies
- Start the Vite development server
- Enable hot module replacement (HMR)
- Watch for file changes

### Production Build
For production deployment, run:
```bash
npm install
npm run build
```
This will:
- Install all frontend dependencies
- Compile and minify all assets
- Generate versioned files in `public/build`
- Optimize images and other assets

### Build Folder Structure
The `public/build` directory contains:
- Compiled JavaScript files
- Processed CSS files
- Optimized images
- Versioned assets for cache busting

### Important Notes
1. The build folder should be:
   - Included in version control
   - Deployed to production
   - Not modified manually

2. After deployment:
   - Clear the view cache: `php artisan view:clear`
   - Clear the config cache: `php artisan config:clear`
   - Restart your web server

## Web Server Setup

### Nginx Configuration
Create a new server block in `/etc/nginx/sites-available/message-board`:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/message-board/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Deny access to sensitive files
    location ~ /\. {
        deny all;
    }
}
```

### Nginx Setup Steps
1. Create the configuration file:
   ```bash
   sudo nano /etc/nginx/sites-available/message-board
   ```

2. Create a symbolic link:
   ```bash
   sudo ln -s /etc/nginx/sites-available/message-board /etc/nginx/sites-enabled/
   ```

3. Test the configuration:
   ```bash
   sudo nginx -t
   ```

4. Restart Nginx:
   ```bash
   sudo systemctl restart nginx
   ```

5. Set proper permissions using the setup script:
   ```bash
   # Make the script executable
   chmod +x setup_permissions.py
   
   # Run the script (as root or with sudo)
   sudo ./setup_permissions.py /path/to/message-board
   
   # Or specify a different web server user/group
   sudo ./setup_permissions.py /path/to/message-board --user=nginx --group=nginx
   ```

   The script will:
   - Set correct ownership (www-data:www-data by default)
   - Set 755 permissions on application directories
   - Set 775 permissions on storage and cache directories
   - Set 644 permissions on configuration files
   - Create necessary storage subdirectories
   - Handle all files and directories recursively

### SSL Configuration (Optional)
For HTTPS, add these lines to your Nginx configuration:

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # ... rest of your configuration ...
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Performance Optimization
1. Enable Gzip compression:
   ```nginx
   gzip on;
   gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
   ```

2. Configure PHP-FPM:
   ```ini
   pm = dynamic
   pm.max_children = 50
   pm.start_servers = 5
   pm.min_spare_servers = 5
   pm.max_spare_servers = 35
   ```

3. Set up caching:
   ```nginx
   location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
       expires 30d;
       add_header Cache-Control "public, no-transform";
   }
   ```

## Features

### User Authentication
- Secure registration and login
- Password reset functionality
- Email verification
- Remember me feature

### Message Management
- Create, read, update, and delete messages
- YouTube video embedding
- Message timestamps
- User-specific message ownership

### User Interface
- Responsive design
- Bootstrap-based layout
- Card-based message display
- Modal for detailed views
- Success/error notifications

## Troubleshooting

### Common Issues and Solutions

#### Database Connection Issues
1. MySQL Connection Failed
   - Verify MySQL server is running
   - Check database credentials in .env
   - Ensure database exists
   - Verify user permissions

2. SQLite Connection Failed
   - Check file permissions
   - Verify SQLite extension is enabled
   - Ensure correct database path

#### Authentication Issues
1. Login Problems
   - Clear browser cache
   - Check session configuration
   - Verify user credentials
   - Check database connection

2. Registration Issues
   - Verify email settings
   - Check database connection
   - Ensure required fields are filled

#### YouTube Embedding Issues
1. Video Not Displaying
   - Check URL format
   - Verify video is public
   - Test with different video IDs
   - Check internet connection

#### View Issues
1. Page Not Loading
   - Clear view cache: `php artisan view:clear`
   - Check blade syntax
   - Verify asset compilation
   - Check file permissions

### Advanced Troubleshooting
1. Check Laravel logs:
   ```bash
   tail -f storage/logs/laravel.log
   ```

2. Clear all caches:
   ```bash
   php artisan config:clear
   php artisan cache:clear
   php artisan view:clear
   php artisan route:clear
   ```

3. Check database status:
   ```bash
   php artisan migrate:status
   ```

## Support

### Documentation
- [Laravel Documentation](https://laravel.com/docs)
- [Bootstrap Documentation](https://getbootstrap.com/docs)
- [YouTube Embed API](https://developers.google.com/youtube/player_parameters)

### Getting Help
1. Check the application logs in `storage/logs`
2. Review the Laravel documentation
3. Search for similar issues in the repository
4. Create a new issue with:
   - Detailed error message
   - Steps to reproduce
   - Environment details
   - Screenshots if applicable

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License
This project is licensed under the MIT License - see the LICENSE file for details. 