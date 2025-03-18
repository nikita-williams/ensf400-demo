FROM eclipse-temurin:11 AS compiler

ENV GRADLE_VERSION=7.6.1
ENV GRADLE_HOME=/opt/gradle
ENV PATH=${PATH}:${GRADLE_HOME}/bin

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    mkdir -p ${GRADLE_HOME} && \
    unzip -d /opt gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} ${GRADLE_HOME} && \
    rm gradle-${GRADLE_VERSION}-bin.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /project

COPY . .

RUN if [ -f "./gradlew" ]; then chmod +x ./gradlew; fi

RUN if [ -f "./gradlew" ]; then \
        ./gradlew --no-daemon war || ./gradlew --no-daemon build; \
    else \
        gradle --no-daemon war || gradle --no-daemon build; \
    fi

FROM tomcat:9-jre11-temurin-focal

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=compiler /project/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

ENV CATALINA_OPTS="-Xms512m -Xmx1024m"
EXPOSE 8080

CMD ["catalina.sh", "run"]
