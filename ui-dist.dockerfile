FROM node:18-alpine
RUN npm install --global pm2

COPY --chown=node:node /dist /app/dist
COPY --chown=node:node ui/config /app/config
COPY --chown=node:node ui/docker/dspace-ui.json /app/dspace-ui.json

WORKDIR /app
USER node
# ENV NODE_OPTIONS="--max_old_space_size=4096"

ENV NODE_ENV production
EXPOSE 4000
CMD pm2-runtime start dspace-ui.json --json
