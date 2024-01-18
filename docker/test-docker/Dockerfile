FROM node:18-alpine 

RUN apk add --update python3 make g++ && rm -rf /var/cache/apk/*

WORKDIR /app
ENTRYPOINT top -b
CMD -- --ignored-param1