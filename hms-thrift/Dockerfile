FROM centos:centos7

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ARG JAVA_VERSION
RUN yum -y install java-${JAVA_VERSION}-openjdk
ENV JAVA_HOME /usr/lib/jvm/jre

RUN rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm && yum -y -q install mysql

ARG HADOOP_VERSION
RUN cd /tmp && wget http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar xvzf hadoop-${HADOOP_VERSION}.tar.gz && mv hadoop-${HADOOP_VERSION} /opt/hadoop

ARG HIVE_VERSION
RUN cd /tmp && wget https://apache.mivzakim.net/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar xvzf apache-hive-${HIVE_VERSION}-bin.tar.gz && mv apache-hive-${HIVE_VERSION}-bin /opt/hive

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CLASSPATH /opt/hadoop/share/hadoop/tools/lib/*

RUN cd /opt/hive/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar

ADD conf /opt/hive/conf

RUN yum -y install which
CMD /opt/hive/conf/config.sh && dockerize -wait tcp://${HMS_DB_HOST}:${HMS_DB_PORT} -timeout 5m && \
    if [[ -n "${HMS_DB_PASSWORD}" ]]; then credentials="-P ${HMS_DB_PORT} -u ${HMS_DB_USER} -p${HMS_DB_PASSWORD}"; fi && \
    mysql -h ${HMS_DB_HOST} ${credentials:-} -e "create database if not exists \`${HMS_DB_NAME}\`;" && \
    v=`mysql -sN -h ${HMS_DB_HOST} ${credentials:-} ${HMS_DB_NAME} -e "SELECT SCHEMA_VERSION FROM VERSION"`; EXIT_CODE=$? && echo "$v $EXIT_CODE" && \
    if [[ $EXIT_CODE -ne 0 ]]; then cd /opt/hive/scripts/metastore/upgrade/mysql && mysql -h ${HMS_DB_HOST} ${credentials:-} ${HMS_DB_NAME} <$(ls hive-schema-* | sort -r | head -1); fi && \
    /opt/hive/bin/hive --hiveconf javax.jdo.option.ConnectionPassword=${HMS_DB_PASSWORD} --service metastore
