#!/usr/bin/env bash
#Bash script that sets up your web servers for the deployment of web_static

sudo apt-get update
sudo apt-get -y install nginx
sudo ufw allow 'Nginx HTTP'

sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/
touch /data/web_static/releases/test/index.html

echo "Holberton School" > /data/web_static/releases/test/index.html
ln -sf /data/web_static/releases/test/ /data/web_static/current
sudo chown -R ubuntu:ubuntu /data/

printf %s "server {
	listen 80;
	listen [::]:80 default_server;
	root   /usr/share/nginx/html;
	index  index.html index.htm;
    add_header X-Served-By $HOSTNAME;

    location /hbnb_static {
        alias /data/web_static/current;
        index index.html index.htm;
    }

    location /redirect_me {
		return 301 http://youtube.com/;
	}

	error_page 404 /notfound.html;
	location = /notfound {
		root /usr/share/nginx/html;
		internal;
	}
}" > /etc/nginx/sites-available/default

sudo service nginx restart
