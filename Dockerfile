# Stage 1 — Build stage (optional if Jenkins already builds)
FROM eclipse-temurin:17-jdk AS build

WORKDIR /app
COPY Additions/target/*.jar app.jar

# Stage 2 — Run stage
FROM eclipse-temurin:17-jre

WORKDIR /app
COPY --from=build /app/app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
