FROM centos:centos7

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN yum -y install java-1.8.0-openjdk
ENV JAVA_HOME /usr/lib/jvm/jre

RUN rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm && yum -y -q install mysql

RUN cd /tmp && wget http://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz && \
    tar xvzf hadoop-3.1.1.tar.gz && mv hadoop-3.1.1 /opt/hadoop

RUN cd /tmp && wget https://apache.mivzakim.net/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
    tar xvzf apache-hive-3.1.2-bin.tar.gz && mv apache-hive-3.1.2-bin /opt/hive

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CLASSPATH /opt/hadoop/share/hadoop/tools/lib/*

RUN cd /opt/hive/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar

ADD conf /opt/hive/conf

ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV HMS_DB_HOST="hms-db"
ENV HMS_DB_PORT=3306
ENV HMS_DB_NAME="hms"
ENV HMS_DB_USER="root"
ENV HMS_DB_PASSWORD=""

CMD /opt/hive/conf/config.sh && dockerize -wait tcp://${HMS_DB_HOST}:${HMS_DB_PORT} -timeout 5m && \
    if [[ -n "${HMS_DB_PASSWORD}" ]]; then credentials="-P ${HMS_DB_PORT} -u ${HMS_DB_USER} -p${HMS_DB_PASSWORD}"; fi && \
    mysql -h ${HMS_DB_HOST} ${credentials:-} -e "create database if not exists \`${HMS_DB_NAME}\`;" && \
    v=`mysql -sN -h ${HMS_DB_HOST} ${credentials:-} ${HMS_DB_NAME} -e "SELECT SCHEMA_VERSION FROM VERSION"`; EXIT_CODE=$? && echo "$v $EXIT_CODE" && \
    if [[ $EXIT_CODE -ne 0 ]]; then mysql -h ${HMS_DB_HOST} ${credentials:-} ${HMS_DB_NAME} </opt/hive/scripts/metastore/upgrade/mysql/hive-schema-3.1.0.mysql.sql; fi && \
    /opt/hive/bin/hive --hiveconf javax.jdo.option.ConnectionPassword=${HMS_DB_PASSWORD} --service metastore
