FROM php:apache

RUN a2enmod rewrite

# Copy application files into the container
COPY . /var/www/html/

# Replace `AllowOverride None` with `AllowOverride All` in `<Directory /var/www/>` in `/etc/apache2/apache2.conf`.
RUN sed -ri -e 'N;N;N;s/(<Directory \/var\/www\/>\n)(.*\n)(.*)AllowOverride None/\1\2\3AllowOverride All/;p;d;' /etc/apache2/apache2.conf

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
RUN apt update
RUN apt install -y git protobuf-compiler
RUN composer require google/protobuf
RUN protoc --php_out=proto/php/ --proto_path=proto/prototypes/ $(find proto/prototypes/ -type f)

RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf


CMD apachectl -D FOREGROUND
