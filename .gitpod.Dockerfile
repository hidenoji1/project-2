FROM gitpod/workspace-full:latest

ENV PHP_VERSION="7.2"
ENV APACHE_DOCROOT_IN_REPO="laravel/public"
ARG MYSQL_ROOT_PASSWORD="123456"
ARG MYSQL_DATABASE="laravel"
ARG MYSQL_USER_ID="laravel"
ARG MYSQL_USER_PASSWORD="laravel"

USER root

RUN apt-get update \
 && apt-get install -y apache2 mysql-server mysql-client \
        mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file \
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

RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
 && cd mecab-ipadic-neologd \
 && bin/install-mecab-ipadic-neologd -n -y \
 && ln -s /usr/lib/x86_64-linux-gnu/mecab/dic /usr/lib/mecab/dic
 
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

RUN mkdir /var/run/mysqld \
 && chown -R gitpod:gitpod /var/run/mysqld /usr/share/mysql /var/lib/mysql /var/log/mysql /etc/mysql \
 && echo "[mysqld_safe] \n\
socket=/var/run/mysqld/mysqld.sock \n\
nice=0 \n\
[mysqld] \n\
user=gitpod \n\
pid-file=/var/run/mysqld/mysqld.pid \n\
socket=/var/run/mysqld/mysqld.sock \n\
port=3306 \n\
basedir=/usr \n\
datadir=/var/lib/mysql \n\
tmpdir=/tmp \n\
lc-messages-dir=/usr/share/mysql \n\
skip-external-locking \n\
bind-address=0.0.0.0 \n\
key_buffer_size=16M \n\
max_allowed_packet=16M \n\
thread_stack=192K \n\
thread_cache_size=8 \n\
myisam-recover-options=BACKUP \n\
query_cache_limit=1M \n\
query_cache_size=16M \n\
general_log_file=/var/log/mysql/mysql.log \n\
general_log=1\n\
log_error=/var/log/mysql/error.log \n\
expire_logs_days=10 \n\
max_binlog_size=100M" >> /etc/mysql/conf.d/my.cnf 

USER gitpod

RUN mysqld --daemonize --skip-grant-tables \
    && sleep 3 \
    && ( mysql -uroot -e "CREATE DATABASE ${MYSQL_DATABASE}; CREATE USER ${MYSQL_USER_ID} IDENTIFIED BY \'${MYSQL_USER_PASSWORD}\';" ) \
    && ( mysql -uroot -e "USE mysql; UPDATE user SET authentication_string=PASSWORD(\"${MYSQL_ROOT_PASSWORD}\") WHERE user='root'; UPDATE user SET plugin=\"mysql_native_password\" WHERE user='root'; FLUSH PRIVILEGES;" ) \
    && mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown;
    
USER root

