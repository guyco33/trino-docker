FROM centos:centos7

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN yum -y -q install java-11-openjdk-devel
ENV JAVA_HOME /usr/lib/jvm/java-11

ARG presto_version
COPY conf/config.sh presto-server-${presto_version}.tar.gz* /tmp/
RUN if [[ ! -f /tmp/presto-server-${presto_version}.tar.gz ]]; then wget -P /tmp/ -c https://repo1.maven.org/maven2/io/prestosql/presto-server/${presto_version}/presto-server-${presto_version}.tar.gz; fi

RUN cd /tmp/ && tar xvzf presto-server-${presto_version}.tar.gz && mv presto-server-${presto_version} /opt/presto

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

RUN mkdir -p /data/presto

EXPOSE 8080

COPY conf/default /opt/presto/.
COPY conf/config.sh /opt/presto/.

# TODO: mount /user/hive/warehouse/ to s3

ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV ICEBERG_DIR=""

CMD /opt/presto/config.sh && /opt/presto/bin/launcher start && sleep 30 && tail -f /data/presto/var/log/launcher.log
