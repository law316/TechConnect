# ---------- STAGE 1: BUILD ----------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy pom first to leverage Docker cache
COPY pom.xml .

# Copy source code
COPY src ./src

# Build the project, skip tests, verify JAR exists
RUN mvn clean package -DskipTests \
    && echo "Listing target folder:" \
    && ls -l target/

# ---------- STAGE 2: RUN ----------
FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /app

# Copy the JAR from the builder stage
# Use wildcard to handle versioned JAR automatically
COPY --from=builder /app/target/*-SNAPSHOT.jar app.jar

# Expose application port
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
