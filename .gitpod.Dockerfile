FROM gitpod/workspace-full:latest

ENV PHP_VERSION="7.2"
ENV APACHE_DOCROOT_IN_REPO="laravel/public"

USER root

RUN apt-get update \
 && apt-get install -y apache2 \
        php${PHP_VERSION} \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-fpm \
        php-xdebug \    
 && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN echo "[xdebug] \n\
xdebug.remote_host=127.0.0.1 \n\
xdebug.remote_port=9002 \n\
xdebug.remote_connect_back=0 \n\
xdebug.idekey=Listen for XDebug \n\
xdebug.remote_autostart=1 \n\
xdebug.remote_enable=1 \n\
xdebug.cli_color=1 \n\
xdebug.profiler_enable=0 \n\
xdebug.remote_handler=dbgp \n\
xdebug.remote_mode=req \n\
xdebug.var_display_max_children=-1 \n\
xdebug.var_display_max_data=-1 \n\
xdebug.var_display_max_depth=-1 \n\
" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini 

RUN sed -ri "s!Listen \*:8001!Listen \*:8080!" -i "/etc/apache2/apache2.conf" 
