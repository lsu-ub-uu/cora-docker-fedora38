# Stage 1: where Fedora installation is run
#
FROM anapsix/alpine-java:8 AS fcrepo

ENV FEDORA_HOME=/home/fedora/fedora38 \
    CATALINA_HOME=/home/fedora/fedora38/tomcat

ADD target/lib/fcrepo-installer-3.8.1.jar .
ADD target/lib/postgresql-9.4.1212.jar .
COPY files/install.properties .

RUN java -jar fcrepo-installer-3.8.1.jar install.properties

WORKDIR $CATALINA_HOME/webapps

COPY files/server.xml $CATALINA_HOME/conf/

RUN keytool -genkey -alias cora-fedora -validity 720 \
        -keyalg RSA -keystore /home/fedora/.keystore  -storetype PKCS12 \
        -dname "CN=fedora.cora.epc.ub.uu.se, OU=Library systems Unit, O=Uppsala University, L=Uppsala, ST=Uppland, C=SE" \
        -storepass changeit -keypass changeit

# Stage 2: start with fresh image and for /home/fedora into the new image
#
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

COPY --from=fcrepo /home/fedora/ .

RUN chown -R $USER_NAME: *

USER $USER_NAME

EXPOSE 8088 8443 61616

CMD ["catalina.sh", "run"]


# build with
# mvn build OR
# docker build --force-rm --pull -t cora-fedora:3.8.1 .


















