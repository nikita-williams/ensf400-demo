# Begin with JDK 11 image as foundation
FROM eclipse-temurin:11 AS compiler

# Configure environment
ENV GRADLE_VERSION=7.6.1
ENV GRADLE_HOME=/opt/gradle
ENV PATH=${PATH}:${GRADLE_HOME}/bin

# Install required tools
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    mkdir -p ${GRADLE_HOME} && \
    unzip -d /opt gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} ${GRADLE_HOME} && \
    rm gradle-${GRADLE_VERSION}-bin.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create project directory
WORKDIR /project

# Copy the entire project
COPY . .

# Make gradlew executable (if it exists)
RUN if [ -f "./gradlew" ]; then chmod +x ./gradlew; fi

# Build the application using gradlew if available, otherwise use installed gradle
RUN if [ -f "./gradlew" ]; then \
        ./gradlew --no-daemon war || ./gradlew --no-daemon build; \
    else \
        gradle --no-daemon war || gradle --no-daemon build; \
    fi

# Create lightweight distribution
FROM tomcat:9-jre11-temurin-focal

# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Add application - with fallback paths to handle different build outputs
COPY --from=compiler /project/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

# Configure runtime environment
ENV CATALINA_OPTS="-Xms512m -Xmx1024m"
EXPOSE 8080

# Initialize server
CMD ["catalina.sh", "run"]
