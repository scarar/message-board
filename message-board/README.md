<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

You may also try the [Laravel Bootcamp](https://bootcamp.laravel.com), where you will be guided through building a modern Laravel application from scratch.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com/)**
- **[Tighten Co.](https://tighten.co)**
- **[WebReinvent](https://webreinvent.com/)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel/)**
- **[Cyber-Duck](https://cyber-duck.co.uk)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Jump24](https://jump24.co.uk)**
- **[Redberry](https://redberry.international/laravel/)**
- **[Active Logic](https://activelogic.com)**
- **[byte5](https://byte5.de)**
- **[OP.GG](https://op.gg)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

# Message Board Application

A secure and feature-rich message board application built with Laravel.

## Quick Installation

You can install the application using a single command:

```bash
# One-line installation (recommended for production)
wget -O install.sh https://raw.githubusercontent.com/yourusername/message-board/main/install.sh && chmod +x install.sh && sudo ./install.sh

# Or step by step (recommended for development)
wget https://raw.githubusercontent.com/yourusername/message-board/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

### Installation Options

During installation, you'll be prompted to choose:

1. **Environment**:
   - Development (with debugging enabled)
   - Production (optimized for performance)

2. **Database**:
   - MySQL (recommended for production)
   - SQLite (recommended for development)

3. **Security Features**:
   - UFW Firewall
   - Fail2ban
   - Automatic security updates

4. **Monitoring**:
   - Monit
   - Log rotation

### Verification

The installation script includes comprehensive verification steps:

- PHP installation and configuration
- Nginx setup
- Database connectivity
- Laravel installation
- Service status checks
- Security features (if enabled)
- Monitoring services (if enabled)

### Post-Installation

After successful installation, you'll receive:

- Regular URL: http://your-domain
- Tor URL: http://your-onion-address
- Default admin credentials
- Summary of enabled features

## Manual Installation

If you prefer to install manually, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/message-board.git
   cd message-board
   ```

2. Install dependencies:
   ```bash
   composer install
   npm install
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. Set up database:
   ```bash
   php artisan migrate
   php artisan db:seed
   ```

5. Build assets:
   ```bash
   npm run build
   ```

## Requirements

- PHP 8.4 or higher
- MySQL 5.7+ or SQLite 3
- Node.js 18+
- Nginx
- Composer
- Tor (for onion service)

## Security Features

- UFW Firewall configuration
- Fail2ban protection
- Automatic security updates
- Secure session handling
- CSRF protection
- XSS protection
- SQL injection prevention

## Monitoring

- Monit process monitoring
- Log rotation
- Resource usage tracking
- Automatic service recovery

## Performance Optimizations

- Redis caching
- PHP OPcache
- Nginx performance tuning
- Database optimization
- Asset compilation
- Route caching

## Troubleshooting

If you encounter any issues during installation:

1. Check the installation logs
2. Verify all services are running
3. Check file permissions
4. Review error logs in `/var/log/nginx/error.log`
5. Check Laravel logs in `storage/logs/laravel.log`

## Support

For support, please:
1. Check the [documentation](docs/)
2. Review [common issues](docs/troubleshooting.md)
3. Open an issue on GitHub

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
