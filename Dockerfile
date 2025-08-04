# Stage 1: Build application
FROM eclipse-temurin:17-jdk-alpine as builder
WORKDIR /workspace/app

# Cache dependencies separately
COPY gradle gradle
COPY build.gradle.kts settings.gradle.kts ./
RUN ./gradlew dependencies --no-daemon

# Build application
COPY src src
COPY .git .git  # Needed for build-info
RUN ./gradlew clean build --no-daemon -x test

# Stage 2: Production image
FROM eclipse-temurin:17-jre-alpine
VOLUME /tmp
EXPOSE 8080

# Security: Run as non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy built artifact
ARG JAR_FILE=build/libs/*.jar
COPY --from=builder --chown=spring:spring /workspace/app/${JAR_FILE} app.jar

# Production JVM flags
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+UseG1GC"

# Health check and entrypoint
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -jar /app.jar"]