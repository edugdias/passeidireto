FROM node:8

WORKDIR /usr/src/app

COPY ./source/package.json /usr/src/app/package.json
COPY ./source/server.js /usr/src/app/server.js

RUN npm install

CMD [ "npm", "start" ]
