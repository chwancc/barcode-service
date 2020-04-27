FROM daocloud.io/node:13
MAINTAINER chwan <mail@chwan.cc>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY package.json /usr/src/app/
RUN npm install --registry https://registry.npm.taobao.org
COPY . /usr/src/app
EXPOSE 3000

ENTRYPOINT ["npm", "start"]