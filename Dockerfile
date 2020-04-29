FROM daocloud.io/library/nginx:1.13.2
MAINTAINER chwan <mail@chwan.cc>

WORKDIR /usr/src/app

RUN mkdir -p /usr/src/app \
COPY package.json /usr/src/app/

RUN apt-get update && apt-get upgrade -y \
&& apt-get install sudo -y \

COPY ./config/nginxconfig.io-yitsao.com /etc/nginx

RUN apt-get install certbot python-certbot-nginx curl -y \

RUN curl -sSL https://deb.nodesource.com/setup_10.x | bash - \
&& apt-get install -y nodejs \
&& openssl dhparam -out /etc/nginx/dhparam.pem 2048 \
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