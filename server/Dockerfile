FROM centos:centos8

RUN yum -y -q update && yum install -y wget
RUN yum -y install python3 && alternatives --set python /usr/bin/python3

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ARG JAVA_VERSION
RUN rpm --import https://www.azul.com/files/0xB1998361219BD9C9.txt
RUN dnf -y install https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm
RUN yum -y install zulu${JAVA_VERSION}-jre
ENV JAVA_HOME /usr/lib/jvm/jre

ARG TRINO_VERSION
COPY for_conditional_copy target/trino-server-${TRINO_VERSION}.tar.gz* /tmp/
RUN if [[ ! -f /tmp/trino-server-${TRINO_VERSION}.tar.gz ]]; then wget -P /tmp/ -c https://repo1.maven.org/maven2/io/trino/trino-server/${TRINO_VERSION}/trino-server-${TRINO_VERSION}.tar.gz; fi

RUN cd /tmp/ && tar xvzf trino-server-${TRINO_VERSION}.tar.gz && mv trino-server-${TRINO_VERSION} /opt/trino

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

RUN mkdir -p /data/trino

EXPOSE 8080

COPY conf/default /opt/trino/.
COPY conf/config.sh /opt/trino/.

# TODO: mount /user/hive/warehouse/ to s3

CMD /opt/trino/config.sh && /opt/trino/bin/launcher start && sleep 30 && tail -f /data/trino/var/log/launcher.log
