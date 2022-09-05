ARG JAVA_VERSION
FROM azul/zulu-openjdk-centos:${JAVA_VERSION}

RUN yum install -y wget

ARG TRINO_VERSION
COPY ./files/tmp /tmp/
RUN if [[ ! -f /tmp/trino-server-${TRINO_VERSION}.tar.gz ]]; then wget -P /tmp/ -c https://repo1.maven.org/maven2/io/trino/trino-server/${TRINO_VERSION}/trino-server-${TRINO_VERSION}.tar.gz; fi
ADD ./files /
RUN tar -C /opt/trino -xvzf /tmp/trino-server-${TRINO_VERSION}.tar.gz --strip 1

RUN \
    yum -q clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/* /var/tmp/* && \
    mkdir -p /data/trino


EXPOSE 8080
ENV LANG en_US.UTF-8
CMD ["/root/run-trino.sh"]
