FROM php:8.1.0-apache
COPY ./application/composer.lock ./application/composer.json /var/www/html/
COPY .docker/php/vhost.conf /etc/apache2/sites-available/000-default.conf
# Define o diretorio padrão
WORKDIR /var/www/html

USER root

# Instala expensões e dependencias do PHP
RUN apt-get update && apt-get install -y \
  libpng-dev \
  libpq-dev \
  zlib1g-dev \
  libxml2-dev \
  libzip-dev \
  libonig-dev \
  zip \
  curl \
  unzip \
  && docker-php-ext-configure gd \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-install pdo_pgsql \
  && docker-php-ext-install pdo \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install pgsql \
  && docker-php-ext-install exif \
  && docker-php-ext-install zip \
  && docker-php-source delete

# Limpa o cahe
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Baixa Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia a aplicação para o container
COPY ./application /var/www/html

# Instala o NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - 
RUN apt-get install -y nodejs
# RUN npm install
# RUN npm run dev
RUN a2enmod rewrite


# Copia os arquivos de configuração do Supervisor
COPY ./.docker/supervisor /etc/supervisor/conf.d
