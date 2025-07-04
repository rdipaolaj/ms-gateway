# Etapa 1: builder con JDK 24 + Maven
FROM eclipse-temurin:24-jdk AS builder
WORKDIR /app

RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:24-jre AS runtime
WORKDIR /app

COPY --from=builder /app/target/ms-gateway-0.0.1-SNAPSHOT.jar app.jar

# Puerto del gateway
EXPOSE 8762

ENTRYPOINT ["java", "-jar", "app.jar"]
