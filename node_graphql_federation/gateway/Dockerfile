#
# To build:
#     docker build . --tag jeantessier/book_reviews-node_graphql_federation-gateway:$(perl -n -e 'print $1 if /"version": "(.*)"/' package.json) --tag jeantessier/book_reviews-node_graphql_federation-gateway:latest
#
# To upload to hub.docker.com:
#     docker push jeantessier/book_reviews-node_graphql_federation-gateway:$(perl -n -e 'print $1 if /"version": "(.*)"/' package.json)
#     docker push jeantessier/book_reviews-node_graphql_federation-gateway:latest
#

FROM node:alpine

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

ENV BOOKS_SERVICE=http://books
ENV REVIEWS_SERVICE=http://reviews
ENV USERS_SERVICE=http://users
ENV SEARCH_SERVICE=http://search
ENV SIGNATURES_SERVICE=http://signatures
ENV JWTS_SERVICE=http://jwts

ENV PORT=80

CMD [ "npm", "start" ]
