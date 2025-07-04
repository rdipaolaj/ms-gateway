# Etapa 1: Builder con JDK 24 + Maven
FROM eclipse-temurin:24-jdk AS builder
WORKDIR /app

RUN apt-get update \
 && apt-get install -y maven \
 && rm -rf /var/lib/apt/lists/*

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Runtime con JRE 24
FROM eclipse-temurin:24-jre AS runtime
WORKDIR /app

# Asegúrate de que Spring Boot lea el PORT que Fly inyecta
ENV PORT=8762

# Copia el JAR generado
COPY --from=builder /app/target/ms-gateway-0.0.1-SNAPSHOT.jar app.jar

# Expón el mismo puerto en el que tu aplicación escucha
EXPOSE 8762

# ENTRYPOINT en una sola línea como array JSON
ENTRYPOINT ["java","-Djava.net.preferIPv4Stack=true","-Dserver.port=${PORT}","-jar","app.jar"]
