FROM anapsix/alpine-java:8 AS build

ENV FEDORA_HOME=/home/fedora/fedora38 \
    CATALINA_HOME=/home/fedora/fedora38/tomcat

ADD http://epc.ub.uu.se/downloads/fcrepo-installer-3.8.1.jar .
ADD http://epc.ub.uu.se/downloads/postgresql-9.4.1208.jar .
COPY install.properties .

RUN java -jar fcrepo-installer-3.8.1.jar install.properties

WORKDIR $CATALINA_HOME/webapps

COPY server.xml $CATALINA_HOME/conf/

RUN rm -fR saxon examples fedora-demo imagemanip fop && \
    rm fedora-demo.war imagemanip.war fop.war

FROM anapsix/alpine-java:8

ENV USER_NAME=fedora \
    USER_HOME=/home/fedora \
    FEDORA_HOME=/home/fedora/fedora38 \
    CATALINA_HOME=/home/fedora/fedora38/tomcat \
    PATH=/home/fedora/fedora38/tomcat/bin:$PATH

RUN delgroup ping && \
    addgroup -g 999 $USER_NAME && \
    adduser -D -u 999 -G $USER_NAME $USER_NAME

WORKDIR $USER_HOME

COPY --from=build /home/fedora/ .

RUN chown -R $USER_NAME: *

USER $USER_NAME

EXPOSE 8088 8443 61616

CMD ["catalina.sh", "run"]


# build with
# mvn build OR
# docker build --force-rm --pull -t cora-fedora:3.8.1 .


















