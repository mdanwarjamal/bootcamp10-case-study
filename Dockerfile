FROM openjdk:8-alpine
LABEL version="2.0" author="Md Anwar Jamal" desc="Case Study Spring Boot Application"
COPY target/bootcamp-0.0.1-SNAPSHOT.jar /usr/local/app/bootcamp.jar
WORKDIR /usr/local/app
ENTRYPOINT [ "java", "-jar", "bootcamp.jar" ]
