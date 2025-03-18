# use gradle 7.6, jdk-11
FROM gradle:7.6-jdk11 AS builder
WORKDIR /home/gradle/project

# Copy all project files into the container
COPY . .

# Update the package lists to fetch the latest versions of available packages
RUN apt-get update

# Installing dependencies
RUN apt-get install -y python3 python3-pip curl unzip

# Cleaning up the cache to reduce image size
RUN apt-get clean

# Clean and build project, without daemon
RUN gradle clean build --no-daemon --refresh-dependencies

FROM tomcat:9-jre11

# Working dir inside tomcat container
WORKDIR /usr/local/tomcat/webapps
RUN rm -rf ROOT
# Copy war file 
COPY --from=builder /home/gradle/project/build/libs/*.war ./ROOT.war

# Expose port 8080
EXPOSE 8080