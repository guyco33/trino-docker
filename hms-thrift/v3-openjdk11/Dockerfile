FROM centos:centos7

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN yum -y -q install java-11-openjdk-devel
ENV JAVA_HOME /usr/lib/jvm/java-11

RUN rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm && yum -y -q install mysql

RUN cd /tmp && wget http://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz && \
    tar xvzf hadoop-3.1.1.tar.gz && mv hadoop-3.1.1 /opt/hadoop

RUN cd /tmp && wget https://apache.mivzakim.net/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
    tar xvzf apache-hive-3.1.2-bin.tar.gz && mv apache-hive-3.1.2-bin /opt/hive

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CLASSPATH /opt/hadoop/share/hadoop/tools/lib/*

RUN cd /opt/hive/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar

ARG aws_access_key
ARG aws_secret_key
COPY hive-site.template.xml /opt/hive/conf/.
COPY hive-site.s3-template.xml /opt/hive/conf/.
RUN if [[ -z "$aws_access_key" ]]; \
    then cp /opt/hive/conf/hive-site.template.xml /opt/hive/conf/hive-site.xml;  \
    else cp /opt/hive/conf/hive-site.s3-template.xml /opt/hive/conf/hive-site.xml;  \
        sed -i \
        -e "s|%AWS_ACCESS_KEY%|${aws_access_key}|g"  \
        -e "s|%AWS_SECRET_KEY%|${aws_secret_key}|g" \
        /opt/hive/conf/hive-site.xml; \
    fi

CMD dockerize -wait tcp://hms-db:3306 -timeout 5m && \
    mysql -h hms-db -e "create database if not exists hms;" && \
    v=`mysql -sN -h hms-db hms -e "SELECT SCHEMA_VERSION FROM VERSION"`; EXIT_CODE=$? && echo $EXIT_CODE && \
    if [[ $EXIT_CODE -ne 0 ]]; then mysql -h hms-db hms </opt/hive/scripts/metastore/upgrade/mysql/hive-schema-3.1.0.mysql.sql; fi && \
    /opt/hive/bin/hive --hiveconf javax.jdo.option.ConnectionPassword= --service metastore
