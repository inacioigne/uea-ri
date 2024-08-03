ARG DSPACE_VERSION=dspace-8.0
ARG JDK_VERSION=17

# Step 1 - Run Maven Build
FROM dspace/dspace-dependencies:${DSPACE_VERSION} as build

WORKDIR /app

RUN mkdir /install \
    && chown -Rv dspace: /install \
    && chown -Rv dspace: /app

USER dspace

ADD --chown=dspace /api/ /app/

RUN mvn clean && mvn package && \
    mv /app/dspace/target/dspace-installer/* /install && \
    mvn clean

# Step 2 - Run Ant Deploy
FROM eclipse-temurin:${JDK_VERSION} as ant_build

COPY --from=build /install /dspace-src
WORKDIR /dspace-src

ENV ANT_VERSION 1.10.13
ENV ANT_HOME /tmp/ant-$ANT_VERSION
ENV PATH $ANT_HOME/bin:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir $ANT_HOME && \
    wget -qO- "https://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C $ANT_HOME

RUN ant init_installation update_configs update_code update_webapps

# Step 3 - Start up DSpace via Runnable JAR
FROM eclipse-temurin:${JDK_VERSION}

ENV DSPACE_INSTALL=/dspace

COPY --from=ant_build /dspace $DSPACE_INSTALL
WORKDIR $DSPACE_INSTALL
EXPOSE 8080
ENV JAVA_OPTS=-Xmx2000m
# ENTRYPOINT ["java", "-jar", "webapps/server-boot.jar", "--dspace.dir=$DSPACE_INSTALL"]

CMD ["sleep", "infinity"]