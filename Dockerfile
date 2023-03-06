FROM maven:3.6.0-jdk-8-alpine AS builder

# 修改maven镜像源
COPY settings.xml /usr/share/maven/conf/settings.xml

ADD ./pom.xml pom.xml
ADD ./src src/

# RUN mvn dependency:go-offline

# RUN mvn install
RUN mvn clean package

From openjdk:8-jre-alpine

COPY --from=builder target/hello_java-0.0.1-SNAPSHOT.jar hello_java-v1.jar

EXPOSE 8010

CMD ["java", "-jar", "hello_java-v1.jar"]