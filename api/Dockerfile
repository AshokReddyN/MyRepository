# Use an official OpenJDK runtime as a parent image
FROM openjdk:11-jre-slim

# Set the working directory in the container
WORKDIR /app

# Arguments for user and group
ARG APP_USER=appuser
ARG APP_GROUP=appgroup

# Create a non-root user and group
RUN groupadd -r ${APP_GROUP} && useradd --no-log-init -r -g ${APP_GROUP} ${APP_USER}

# Copy the fat JAR file into the container at /app
# The JAR name is derived from artifactId and version in pom.xml
COPY target/user-management-0.0.1-SNAPSHOT.jar app.jar

# Change ownership to the non-root user
RUN chown ${APP_USER}:${APP_GROUP} app.jar

# Switch to the non-root user
USER ${APP_USER}

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Environment variable for Spring profiles (can be overridden at runtime)
ENV SPRING_PROFILES_ACTIVE="dev"
ENV SERVER_PORT="8080"

# Run the JAR file
# Using exec form of ENTRYPOINT to make it the main process (PID 1)
# Allows passing Java system properties and application arguments
ENTRYPOINT ["java", \
            "-Dserver.port=${SERVER_PORT}", \
            "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", \
            "-jar", \
            "app.jar"]
