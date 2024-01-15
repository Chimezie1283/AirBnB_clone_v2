# Puppet manifest to install nginx and setup some directories and a symlink

exec { 'update-index':
    command => '/usr/bin/apt-get update',
}

package { 'nginx':
    ensure  => installed,
    require => Exec[ 'update-index' ],
}

file { ['/data', '/data/web_static/', '/data/web_static/releases/', '/data/web_static/releases/test/', '/data/web_static/shared/']:
    ensure => directory,
}

exec { 'chown -hR ubuntu:ubuntu /data':
    path    => '/usr/bin/:/usr/local/bin/:/bin/',
    require => File[ '/data' ],
}

file { '/data/web_static/releases/test/index.html':
    ensure  => file,
    content => '<html><head><title>Test HTML File</title></head><body><h1>Hello World!</h1></body></html>',
    require => File[ '/data/web_static/releases/test' ],
}

file { '/data/web_static/current':
    ensure  => link,
    target  => '/data/web_static/releases/test/',
    force   => true,
    require => [File[ '/data/web_static/releases/test/index.html' ], Exec['chown -hR ubuntu:ubuntu /data']],
}

file { '/etc/nginx/sites-available/default':
    ensure  => present,
    content => 'server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name olisabelema.tech www.o;isabelema.tech;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /hbnb_static {
        alias /data/web_static/current/;
        autoindex off;
    }
}',
}

service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => File[ '/etc/nginx/sites-available/default' ],
}
