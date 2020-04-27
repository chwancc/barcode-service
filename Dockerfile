FROM daocloud.io/library/nginx:1.13.2
MAINTAINER chwan <mail@chwan.cc>

WORKDIR /usr/src/app
COPY package.json /usr/src/app/
COPY ./config/nginxconfig.io-yitsao.com /etc/nginx

RUN mkdir -p /usr/src/app \
&& apt update \
&& apt install sudo nodejs certbot python-certbot-nginx -y\
&& openssl dhparam -out /etc/nginx/dhparam.pem 2048 \
&& mkdir -p /var/www/_letsencrypt \
&& chown www-data /var/www/_letsencrypt \
&& sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/sites-available/yitsao.com.conf  \
&& sudo nginx -t && sudo systemctl reload nginx   \
&& certbot certonly --webroot -d yitsao.com -d www.yitsao.com --email 2805566898@qq.com -w /var/www/_letsencrypt -n --agree-tos --force-renewal    \
&& sed -i -r 's/#?;#//g' /etc/nginx/sites-available/yitsao.com.conf         \
&& sudo nginx -t && sudo systemctl reload nginx \
&& echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh   \
&& sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh \
&& sudo nginx -t && sudo systemctl reload nginx \
&& npm install --registry https://registry.npm.taobao.org
COPY ./src /usr/src/app

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["npm", "run start"]