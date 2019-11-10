FROM centos:centos7

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN yum -y -q install java-11-openjdk-devel
ENV JAVA_HOME /usr/lib/jvm/java-11

ARG presto_version
RUN wget -c https://repo1.maven.org/maven2/io/prestosql/presto-server/$presto_version/presto-server-$presto_version.tar.gz

RUN tar xvzf presto-server-$presto_version.tar.gz && mv presto-server-$presto_version /opt/presto

RUN mkdir -p /data/presto

EXPOSE 8080

COPY conf/default /opt/presto/.
# TODO: mount /user/hive/warehouse/ to s3

ARG aws_access_key
ARG aws_secret_key
RUN if [[ -n "$aws_access_key" ]]; \
    then \
        echo >>/opt/presto/etc/catalog/hive.properties; \
        echo "hive.s3.aws-access-key=${aws_access_key}" >>/opt/presto/etc/catalog/hive.properties; \
        echo "hive.s3.aws-secret-key=${aws_secret_key}" >>/opt/presto/etc/catalog/hive.properties; \
    fi

ARG is_worker
ARG is_coordinator
RUN sed -i \
    -e "s|%COORDINATOR%|${is_coordinator}|g"  \
    /opt/presto/etc/config.properties

RUN echo >>/opt/presto/etc/config.properties; \
    if [[ $is_coordinator == 'true' ]]; \
    then \
        echo "discovery.uri=http://localhost:8080" >>/opt/presto/etc/config.properties; \
        echo "discovery-server.enabled=true" >>/opt/presto/etc/config.properties; \
        echo "node-scheduler.include-coordinator=$is_worker" >>/opt/presto/etc/config.properties; \
    else \
        echo "discovery.uri=http://coordinator:8080" >>/opt/presto/etc/config.properties; \
    fi

ARG iceberg_dir
RUN if [[ -z "$iceberg_dir" ]]; \
    then \
        rm /opt/presto/etc/catalog/iceberg.properties; \
    else sed -i \
        -e "s|%ICEBERG_DIR%|${iceberg_dir}|g"  \
        /opt/presto/etc/catalog/iceberg.properties; \
        if [[ -n "$aws_access_key" ]]; \
        then \
            echo >>/opt/presto/etc/catalog/iceberg.properties; \
            echo "hive.s3.aws-access-key=${aws_access_key}" >>/opt/presto/etc/catalog/iceberg.properties; \
            echo "hive.s3.aws-secret-key=${aws_secret_key}" >>/opt/presto/etc/catalog/iceberg.properties; \
        fi; \
    fi

CMD /opt/presto/bin/launcher start && sleep 30 && tail -f /data/presto/var/log/launcher.log
