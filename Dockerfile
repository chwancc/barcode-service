FROM daocloud.io/library/ubuntu:19.10
MAINTAINER chwan <mail@chwan.cc>

WORKDIR /usr/src/app

RUN mkdir -p /usr/src/app \
&& apt-get update && apt-get upgrade -y \
&& apt-get install sudo nginx nodejs certbot python-certbot-nginx -y

COPY package.json /usr/src/app/
COPY ./config/nginxconfig.io-yitsao.com /etc/nginx

RUN openssl dhparam -out /etc/nginx/dhparam.pem 2048 \
&& node -v \
&& npm -version \
&& mkdir -p /var/www/_letsencrypt \
&& chown www-data /var/www/_letsencrypt \
&& npm install --registry https://registry.npm.taobao.org
COPY ./src /usr/src/app

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["npm", "run start"]
CMD ["./config/init.sh"]