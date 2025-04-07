FROM eclipse-temurin:11-jre-alpine AS h2-2.3.232-jre11-alpine
FROM eclipse-temurin:17-jre-alpine AS h2-2.3.232-jre17-alpine
FROM eclipse-temurin:21-jre-alpine AS h2-2.3.232-jre21-alpine

ENV RELEASE_VERSION=2.3.232
ENV H2DATA=/h2-data
ENV H2_DBNAME="mydb"
ENV H2_USER="sa"
ENV H2_PASSWORD=""
ENV H2_OPTIONS=""

WORKDIR /h2/bin/
RUN set -xe; \
  wget -O /h2/bin/h2.jar https://search.maven.org/remotecontent?filepath=com/h2database/h2/${RELEASE_VERSION}/h2-${RELEASE_VERSION}.jar

RUN mkdir /docker-entrypoint-initdb.d

VOLUME $H2DATA

EXPOSE 8082 9092

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["java", "-cp", "/h2/bin/h2.jar", "org.h2.tools.Server", "-web", "-webAllowOthers", "-tcp", "-tcpAllowOthers", "-baseDir", "/h2-data"]

