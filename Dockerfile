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

# Etapa 2: runtime con JRE 24
FROM eclipse-temurin:24-jre AS runtime
WORKDIR /app

# Por defecto Spring usará PORT=8762 si no se le pasa otro
ENV PORT=8762

COPY --from=builder /app/target/ms-gateway-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8762

# Forzamos IPv4 para que Netty escuche en 0.0.0.0
ENTRYPOINT ["java","-Djava.net.preferIPv4Stack=true","-jar","/app/app.jar"]
