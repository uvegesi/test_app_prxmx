# Stage 1: Build the Application
FROM gradle:jdk17-alpine AS builder
WORKDIR /app
COPY . .
# Skip tests to speed up the build in CI (optional)
RUN ./gradlew bootJar --no-daemon -x test

# Stage 2: Create the Runtime Image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]