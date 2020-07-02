# Linux x64
FROM alpine

# LABEL maintainer="maintainer@email.com"

# Install Node and NPM (apk is alpine's package manager tool)
RUN apk add --update nodejs nodejs-npm

# Copy app to /src
COPY . /backend

WORKDIR /backend

# Install dependencies
RUN  npm install

EXPOSE 8080

ENTRYPOINT ["node", "./server.js"]
