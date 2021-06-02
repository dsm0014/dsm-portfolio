FROM openjdk:11-jre-slim
MAINTAINER "Daniel Morrison"
WORKDIR /app
COPY ./build/libs/*.jar ./portfolio.jar
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/portfolio.jar"]