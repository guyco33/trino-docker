FROM azul/zulu-openjdk-centos:11

ENV JAVA_HOME /usr/lib/jvm/zulu11
RUN yum install -y wget

ARG TRINO_VERSION
RUN wget -P /tmp/ -c https://repo1.maven.org/maven2/io/trino/trino-server/${TRINO_VERSION}/trino-server-${TRINO_VERSION}.tar.gz

# Copy configuration files
COPY ./files /
RUN tar -C /opt/trino -xvzf /tmp/trino-server-${TRINO_VERSION}.tar.gz --strip 1

RUN \
    yum -q clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/* /var/tmp/* && \
    mkdir -p /data/trino


EXPOSE 8080
ENV LANG en_US.UTF-8
CMD ["/root/run-trino.sh"]
