FROM php:8.4-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    gettext \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy Laravel source
COPY src/ .

# 🔥 THIS WAS MISSING
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Permissions
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Nginx config template
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf.template

# Render uses PORT env var
EXPOSE 10000

CMD sh -c "\
    envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
    php-fpm & nginx -g 'daemon off;'"
