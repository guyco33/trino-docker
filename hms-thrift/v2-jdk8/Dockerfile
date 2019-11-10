FROM centos:centos7

RUN yum -y -q update && yum install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY lib/jdk-8u171-linux-x64.tar.gz /tmp/.
RUN cd /tmp && tar xvzf jdk-8u171-linux-x64.tar.gz && \
    mkdir -p /usr/lib/jvm/ && mv jdk1.8.0_171 /usr/lib/jvm/
ENV JAVA_HOME /usr/lib/jvm/jdk1.8.0_171

RUN rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm && yum -y -q install mysql

#COPY lib/hadoop-2.7.4.tar.gz /tmp/.
#RUN cd /tmp && tar xvzf hadoop-2.7.4.tar.gz && mv hadoop-2.7.4 /opt/hadoop
#
#COPY lib/apache-hive-2.3.3-bin.tar.gz /tmp/.
#RUN cd /tmp && tar xvzf apache-hive-2.3.3-bin.tar.gz && mv apache-hive-2.3.3-bin /opt/hive

RUN cd /tmp && wget http://archive.apache.org/dist/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz && \
    tar xvzf hadoop-2.7.4.tar.gz && mv hadoop-2.7.4 /opt/hadoop

RUN cd /tmp && wget https://apache.mivzakim.net/hive/hive-2.3.3/apache-hive-2.3.3-bin.tar.gz && \
    tar xvzf apache-hive-2.3.3-bin.tar.gz && mv apache-hive-2.3.3-bin /opt/hive

RUN yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CLASSPATH /opt/hadoop/share/hadoop/tools/lib/*

RUN cd /opt/hive/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar

COPY hive-site.template.xml /opt/hive/conf/.
COPY hive-site.s3-template.xml /opt/hive/conf/.
COPY config.sh /opt/hive/.

ENV AWS_ACCESS_KEY=""
ENV AWS_SECRET_KEY=""

RUN yum -y install which
CMD /opt/hive/config.sh && dockerize -wait tcp://hms-db:3306 -timeout 5m && \
    mysql -h hms-db -e "create database if not exists hms;" && \
    v=`mysql -sN -h hms-db hms -e "SELECT SCHEMA_VERSION FROM VERSION"`; EXIT_CODE=$? && echo $EXIT_CODE && \
    if [[ $EXIT_CODE -ne 0 ]]; then cd /opt/hive/scripts/metastore/upgrade/mysql/ && mysql -h hms-db hms <hive-schema-2.3.0.mysql.sql; fi && \
    /opt/hive/bin/hive --hiveconf javax.jdo.option.ConnectionPassword= --service metastore
