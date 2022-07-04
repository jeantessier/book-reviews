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
