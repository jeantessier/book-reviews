#
# To build:
#     docker build . --tag jeantessier/book_reviews-node_graphql_federation-search:$(perl -n -e 'print $1 if /"version": "(.*)"/' package.json) --tag jeantessier/book_reviews-node_graphql_federation-search:latest
#
# To upload to hub.docker.com:
#     docker push jeantessier/book_reviews-node_graphql_federation-search:$(perl -n -e 'print $1 if /"version": "(.*)"/' package.json)
#     docker push jeantessier/book_reviews-node_graphql_federation-search:latest
#

FROM node:alpine

ARG kafkaClientId=search

# Create app directory
WORKDIR /home/node/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json .

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY *.js .

ENV KAFKA_BOOTSTRAP_SERVER=host.docker.internal:9092
ENV KAFKA_CLIENT_ID=$kafkaClientId

ENV PORT=80

CMD [ "npm", "start" ]
