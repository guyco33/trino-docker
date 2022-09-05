#!/usr/bin/env bash

if [[ -n "${AWS_ACCESS_KEY_ID}" ]]
then
    sed -i  -e "s|%AWS_ACCESS_KEY_ID%|${AWS_ACCESS_KEY_ID}|g" \
            -e "s|%AWS_SECRET_ACCESS_KEY%|${AWS_SECRET_ACCESS_KEY}|g" \
            /opt/hive/conf/hive-site.s3
    sed -i  -e "s|<\!--s3 credentials-->|$(tr -d '\n' < /opt/hive/conf/hive-site.s3)|g" \
            /opt/hive/conf/hive-site.xml
fi

if [[ -n "${GCS_PRIVATE_KEY_ID}" ]]
then
    sed -i  -e "s|%GCS_ACCOUNT_EMAIL%|${GCS_ACCOUNT_EMAIL}|g" \
            -e "s|%GCS_PRIVATE_KEY_ID%|${GCS_PRIVATE_KEY_ID}|g" \
            -e "s|%GCS_PRIVATE_KEY%|$(echo $GCS_PRIVATE_KEY | sed 's/\\n/\\\\n/g')|g" \
            /opt/hive/conf/hive-site.gcs
    sed -i  -e "s|<\!--gcs credentials-->|$(tr -d '\n' < /opt/hive/conf/hive-site.gcs)|g" \
            /opt/hive/conf/hive-site.xml
fi

sed -i  \
    -e "s|%HMS_DB_HOST%|${HMS_DB_HOST}|g"  \
    -e "s|%HMS_DB_PORT%|${HMS_DB_PORT}|g" \
    -e "s|%HMS_DB_NAME%|${HMS_DB_NAME}|g" \
    -e "s|%HMS_DB_USER%|${HMS_DB_USER}|g" \
    /opt/hive/conf/hive-site.xml

if [[ ${HMS_DEBUG} == true ]]
then
  cp /opt/hive/conf/hive-exec-log4j2.properties.template /opt/hive/conf/hive-exec-log4j2.properties
  sed -i -e "s|INFO|DEBUG|g" /opt/hive/conf/hive-exec-log4j2.properties
  cp /opt/hive/conf/hive-log4j2.properties.template /opt/hive/conf/hive-log4j2.properties
  sed -i -e "s|INFO|DEBUG|g" /opt/hive/conf/hive-log4j2.properties
fi

mkdir -p /opt/hadoop/logs
