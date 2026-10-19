
FROM dunglas/frankenphp:1-php8.4-bookworm

# Extensions PHP nécessaires à Cachet / Laravel
RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    pcntl \
    zip \
    opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Code source
COPY . /app

# Dépendances verrouillées par composer.lock
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader \
    --no-scripts

# Dossiers Laravel
RUN mkdir -p \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    public/css \
    public/js \
    public/fonts \
    public/vendor

# Permissions Laravel et assets
RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache \
    public/css \
    public/js \
    public/fonts \
    public/vendor

# Configuration HTTP
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 80

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
