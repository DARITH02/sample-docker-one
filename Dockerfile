# Use PHP 8.4 FPM
FROM php:8.4-fpm

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    gettext \
    libpng-dev libonig-dev libxml2-dev zip unzip git curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy Laravel app
COPY src/. .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set permissions
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Generate key & migrate during build (so free tier works)
RUN php artisan key:generate --ansi \
    && php artisan migrate --force

# Copy Nginx config template
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf.template

# Expose Render’s port
EXPOSE 10000

# Start PHP-FPM + Nginx
CMD sh -c "\
    envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
    php-fpm & nginx -g 'daemon off;'"
