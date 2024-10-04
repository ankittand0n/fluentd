# Use an official OpenJDK 20 runtime as a parent image
FROM openjdk:latest

# Set the working directory
WORKDIR /app

# Copy the application JAR file
COPY build/libs/demo-0.0.1-SNAPSHOT.jar /app/demo.jar

# Expose the port the application runs on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/demo.jar"]

# Optional: Add a health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1