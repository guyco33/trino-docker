FROM centos:centos8

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget -P /tmp --no-check-certificate https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar xzf /tmp/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz --directory /usr/local/bin

RUN rpm --import https://www.azul.com/files/0xB1998361219BD9C9.txt && \
    dnf -y install https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm && \
    yum -y install zulu${JAVA_VERSION}-jre
ENV JAVA_HOME /usr/lib/jvm/jre

RUN rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm && \
    yum -y -q install mysql

ARG HADOOP_VERSION
ARG HIVE_VERSION
RUN curl -o /tmp/hadoop-${HADOOP_VERSION}.tar.gz --url http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
RUN curl -o /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz --url https://apache.mivzakim.net/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz

RUN tar xzf /tmp/hadoop-${HADOOP_VERSION}.tar.gz --directory /opt && mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop
RUN tar xzf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz --directory /opt && mv /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive

RUN if [[ ${HIVE_VERSION} == "3.1.2" ]]; then \
    rm /opt/hive/lib/guava-19.0.jar && cp /opt/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /opt/hive/lib/ ; \
    mkdir -p /opt/hive/auxlib && curl -o /opt/hive/auxlib/aws-java-sdk-core-1.11.906.jar --url https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.11.906/aws-java-sdk-core-1.11.906.jar ; \
    fi

ARG GCS_CONNECTOR_VERSION
RUN mkdir -p /opt/hive/auxlib && curl -o /opt/hive/auxlib/gcs-connector-${GCS_CONNECTOR_VERSION}.jar --url https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/${GCS_CONNECTOR_VERSION}/gcs-connector-${GCS_CONNECTOR_VERSION}.jar

RUN curl -o /opt/hive/lib/mysql-connector-java-8.0.13.jar --url https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CLASSPATH /opt/hadoop/share/hadoop/tools/lib/*

ADD conf /opt/hive/conf

RUN yum -y install which
CMD /opt/hive/conf/config.sh && dockerize -wait tcp://${HMS_DB_HOST}:${HMS_DB_PORT} -timeout 5m && \
    if [[ -n "${HMS_DB_PASSWORD}" ]]; then credentials="-P ${HMS_DB_PORT} -u ${HMS_DB_USER} -p${HMS_DB_PASSWORD}"; fi && \
    mysql -h ${HMS_DB_HOST} ${credentials:-} -e "create database if not exists \`${HMS_DB_NAME}\`;" && \
    v=`mysql -sN -h ${HMS_DB_HOST} ${credentials:-} ${HMS_DB_NAME} -e "SELECT SCHEMA_VERSION FROM VERSION"`; EXIT_CODE=$? && echo "$v $EXIT_CODE" && \
    if [[ $EXIT_CODE -ne 0 ]]; then cd /opt/hive/scripts/metastore/upgrade/mysql && mysql -h ${HMS_DB_HOST} ${credentials:-} ${HMS_DB_NAME} <$(ls hive-schema-* | sort -r | head -1); fi && \
    /opt/hive/bin/hive --hiveconf javax.jdo.option.ConnectionPassword=${HMS_DB_PASSWORD} --service metastore
