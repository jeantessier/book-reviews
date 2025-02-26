#
# To build:
#     docker build . --tag jeantessier/book_reviews-node_graphql_federation-vector_search:$(perl -n -e 'print $1 if /"version": "(.*)"/' package.json) --tag jeantessier/book_reviews-node_graphql_federation-vector_search:latest
#
# To upload to hub.docker.com:
#     docker push jeantessier/book_reviews-node_graphql_federation-vector_search:$(perl -n -e 'print $1 if /"version": "(.*)"/' package.json)
#     docker push jeantessier/book_reviews-node_graphql_federation-vector_search:latest
#

FROM node:alpine

ARG serviceName=vector_search

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
ENV KAFKA_CLIENT_ID=$serviceName
ENV OPEN_TELEMETRY_SERVICE_NAME=$serviceName
ENV ZIPKIN_EXPORTER_URL=http://host.docker.internal:9411/api/v2/spans

ENV PORT=80

CMD [ "npm", "start" ]
