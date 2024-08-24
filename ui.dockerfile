FROM node:18-alpine as build

RUN apk add --update python3 make g++ \
    && rm -rf /var/cache/apk/*

WORKDIR /app
COPY ui/package.json ui/yarn.lock ./
RUN yarn install --network-timeout 300000

ADD ./ui /app/
RUN yarn build:prod

FROM node:18-alpine
RUN npm install --global pm2

COPY --chown=node:node --from=build /app/dist /app/dist
COPY --chown=node:node ui/config /app/config
COPY --chown=node:node ui/docker/dspace-ui.json /app/dspace-ui.json

WORKDIR /app
USER node
ENV NODE_OPTIONS="--max_old_space_size=4096"
ENV NODE_ENV production
EXPOSE 4000
CMD pm2-runtime start dspace-ui.json --json
