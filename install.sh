#!/bin/bash
amazon-linux-extras enable nginx1 php7.4
amazon-linux-extras install -y nginx1 php7.4

cat - << 'EOS' > /etc/php-fpm.d/www.conf
[www]
user = apache
group = apache

listen = /run/php-fpm/www.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

listen.allowed_clients = 127.0.0.1
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

slowlog = /var/log/php-fpm/www-slow.log

access.log = /var/log/php-fpm/access.log
php_admin_value[error_log] = /var/log/php-fpm/error.log
php_admin_flag[log_errors] = on

php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
EOS

cat - << 'EOS' > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
EOS

cat - << 'EOS' > /etc/nginx/conf.d/php-fpm.conf
upstream php-fpm {
    server unix:/run/php-fpm/www.sock;
}
EOS

cat - << 'EOS' > /usr/share/nginx/html/index.php
<?php
phpinfo();
EOS

service nginx start
service php-fpm start

systemctl enable nginx
systemctl enable php-fpm
