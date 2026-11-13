FROM php:8.2-apache

# Instala ferramentas de rede e extensões PHP necessárias
RUN apt-get update && apt-get install -y net-tools && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql mysqli

# Habilita mod_rewrite do Apache
RUN a2enmod rewrite

# Configura DocumentRoot para /var/www/html/public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
# O bind mount .env pertence ao usuário local. Em Docker rootless, nem mesmo
# o root do container pode gravá-lo; o Apache usa o UID/GID enviados pelo
# Docker Compose durante o build (1000 é o padrão usual em Ubuntu/Kali).
ARG APP_UID=1000
ARG APP_GID=1000
RUN groupadd --non-unique --gid ${APP_GID} labuser \
    && useradd --non-unique --uid ${APP_UID} --gid ${APP_GID} --create-home --shell /usr/sbin/nologin labuser
ENV APACHE_RUN_USER=labuser
ENV APACHE_RUN_GROUP=labuser

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Ajusta permissões
RUN chown -R www-data:www-data /var/www/html

# Copia o projeto
COPY ./public /var/www/html/public
COPY ./src    /var/www/html/src
COPY ./assets /var/www/html/assets

# Configuração do Apache para AllowOverride (suporte a .htaccess)
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>\n\
Alias /assets/ /var/www/html/assets/\n\
<Directory /var/www/html/assets>\n\
    Options FollowSymLinks\n\
    AllowOverride None\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/lab.conf \
    && a2enconf lab

EXPOSE 80
