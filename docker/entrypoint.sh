#!/bin/sh

# Copy .env if missing
if [ ! -f /var/www/.env ]; then
    cp /var/www/.env.example /var/www/.env
fi

# Generate app key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Replace $PORT in Nginx template
envsubst '$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start PHP-FPM and Nginx
php-fpm & nginx -g 'daemon off;'
