FROM node:alpine

ARG kafkaClientId=reviews

# Create app directory
WORKDIR /home/node/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY *.js .

ENV KAFKA_BOOTSTRAP_SERVER=host.docker.internal:9092
ENV KAFKA_CLIENT_ID=$kafkaClientId

ENV PORT=80

CMD [ "npm", "start" ]
