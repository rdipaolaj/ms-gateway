# Etapa 1: builder con JDK 24 + Maven
FROM eclipse-temurin:24-jdk AS builder
WORKDIR /app
RUN apt-get update \
    && apt-get install -y maven \
    && rm -rf /var/lib/apt/lists/*

COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: runtime con JRE
FROM eclipse-temurin:24-jre AS runtime
WORKDIR /app

# Le decimos a Spring Boot en qué puerto arrancar por defecto
ENV PORT=8762

COPY --from=builder /app/target/ms-gateway-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8762

# arrancamos el jar y forzamos IPv4
ENTRYPOINT ["java","-Djava.net.preferIPv4Stack=true","-jar","/app/app.jar"]
