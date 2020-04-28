FROM daocloud.io/library/nginx:1.17.9
MAINTAINER chwan <mail@chwan.cc>

WORKDIR /usr/src/app
COPY package.json /usr/src/app/
COPY ./config/nginxconfig.io-yitsao.com /etc/nginx

RUN mkdir -p /usr/src/app \
&& apt update \
&& apt install sudo nodejs npm certbot python-certbot-nginx -y

RUN openssl dhparam -out /etc/nginx/dhparam.pem 2048 \
&& mkdir -p /var/www/_letsencrypt \
&& chown www-data /var/www/_letsencrypt \
&& npm install --registry https://registry.npm.taobao.org
COPY ./src /usr/src/app

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["npm", "run start"]
CMD ["./config/init.sh"]