# Stage 1: Build the application JAR
FROM maven:3.8-openjdk-11 AS builder
# Or: FROM eclipse-temurin:11-jdk AS builder (if preferred, ensure Maven is available or install it)

WORKDIR /app

# Copy pom.xml and download dependencies first to leverage Docker cache
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Alternative for downloading dependencies: mvn verify --fail-never (might be more robust)

# Copy the rest of the application source code
COPY src ./src

# Build the application, skipping tests for faster image build
RUN mvn clean package -DskipTests -B

# Stage 2: Create the runtime image
FROM openjdk:11-jre-slim
# Or: FROM eclipse-temurin:11-jre

ARG SPRING_PROFILES_ACTIVE="dev"
ARG SERVER_PORT="8080"

ENV SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
ENV SERVER_PORT=${SERVER_PORT}

WORKDIR /app

# Create a non-root user and group
# Note: The original Dockerfile had ARGs for APP_USER and APP_GROUP,
# if those are intended for customization, they should be added here as well.
# For simplicity, using fixed names as per the provided multi-stage example.
RUN groupadd -r appgroup && useradd --no-log-init -r -g appgroup appuser

# Copy the JAR from the builder stage
# Ensure the JAR path matches the output from 'mvn package'
COPY --from=builder /app/target/user-management-0.0.1-SNAPSHOT.jar app.jar

# Set ownership and switch to non-root user
RUN chown appuser:appgroup app.jar
USER appuser

EXPOSE ${SERVER_PORT}

ENTRYPOINT ["java","-Dserver.port=${SERVER_PORT}","-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}","-jar","app.jar"]
