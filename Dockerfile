FROM node:16-alpine3.15

# Install the web browser (package firefox-esr is available too)
RUN apk update 
# && \
#     apk add --no-cache firefox dumb-init && \
#     rm -Rf /var/cache
# Install Chromium and dumb-init and remove all locales but en-US
RUN apk add --no-cache chromium dumb-init && \
    find /usr/lib/chromium/locales -type f ! -name 'en-US.*' -delete
# Copy FlareSolverr code
USER node
RUN mkdir -p /home/node/flaresolverr
WORKDIR /home/node/flaresolverr
COPY --chown=node:node package.json package-lock.json tsconfig.json install.js ./
COPY --chown=node:node src ./src/

# Install package. Skip installing the browser, we will use the installed package.
# ENV PUPPETEER_PRODUCT=firefox \
#     PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
#     PUPPETEER_EXECUTABLE_PATH=/usr/bin/firefox

ENV PUPPETEER_PRODUCT=chrome \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN npm install && \
    npm run build && \
    npm prune --production && \
    rm -rf /home/node/.npm

EXPOSE 8191
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "./dist/server.js"]

# docker build -t flaresolverr:custom .
# docker run -p 8191:8191 -e LOG_LEVEL=debug flaresolverr:custom
