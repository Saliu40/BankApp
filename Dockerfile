# ---------- Build Stage ----------
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml first to leverage Docker cache
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn -B -DskipTests package

# ---------- Runtime Stage ----------
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Create non-root user
RUN useradd -m appuser
USER appuser

# Copy only the jar
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
