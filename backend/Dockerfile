# Stage 1 to build jar file gradle:8.6.0-jdk17
FROM gradle:8.6.0-jdk17 as build
VOLUME /tmp
WORKDIR /app
COPY . /app
RUN gradle clean build

#Stage 2 to run the jar file
FROM openjdk:17
COPY --from=build /app/build/libs/student_support_system_app.jar /student_support_system_app.jar
EXPOSE 8080
CMD ["java", "-jar", "student_support_system_app.jar"]