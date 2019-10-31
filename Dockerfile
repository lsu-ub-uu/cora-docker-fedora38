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

# create this directories, because only then mappping to a volume works
RUN mkdir -p $FEDORA_HOME/data $FEDORA_HOME/server/logs

# SSL is deactivated
# RUN keytool -genkey -alias cora-fedora -validity 720 \
#        -keyalg RSA -keystore /home/fedora/.keystore  -storetype PKCS12 \
#        -dname "CN=fedora.cora.epc.ub.uu.se, OU=Library systems Unit, O=Uppsala University, L=Uppsala, ST=Uppland, C=SE" \
#        -storepass changeit -keypass changeit

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

ADD files/policies.tgz $FEDORA_HOME/data/
COPY files/deny-apim-if-not-localhost.xml $FEDORA_HOME/data/fedora-xacml-policies/repository-policies/default/

COPY files/fedoraKeystore.jks .keystore
COPY files/fedoraDockerPublicKey.pem $FEDORA_HOME/fedoraDockerPublicKey.pem

RUN chown -R $USER_NAME: .

USER $USER_NAME

RUN keytool  -import -noprompt -alias fedoraDockerCert -keystore $FEDORA_HOME/client/truststore -file  $FEDORA_HOME/fedoraDockerPublicKey.pem -storepass tomcat

VOLUME $FEDORA_HOME/data
VOLUME $FEDORA_HOME/server/logs
VOLUME $FEDORA_HOME/tomcat/logs

EXPOSE 8088 8443 61616

CMD ["catalina.sh", "run"]


# build with
# mvn package

# run with
# scripts/start.sh

# stop with
# scripts/stop.sh



















