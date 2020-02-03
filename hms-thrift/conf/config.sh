#!/usr/bin/env bash

if [[ -n "${AWS_ACCESS_KEY_ID}" ]]
then
    cp /opt/hive/conf/hive-site.s3-template.xml /opt/hive/conf/hive-site.xml
    sed -i  -e "s|%AWS_ACCESS_KEY%|${AWS_ACCESS_KEY_ID}|g"  -e "s|%AWS_SECRET_KEY%|${AWS_SECRET_ACCESS_KEY}|g" /opt/hive/conf/hive-site.xml
else
    cp /opt/hive/conf/hive-site.template.xml /opt/hive/conf/hive-site.xml
fi

sed -i  \
    -e "s|%HMS_DB_HOST%|${HMS_DB_HOST}|g"  \
    -e "s|%HMS_DB_PORT%|${HMS_DB_PORT}|g" \
    -e "s|%HMS_DB_NAME%|${HMS_DB_NAME}|g" \
    -e "s|%HMS_DB_USER%|${HMS_DB_USER}|g" \
    /opt/hive/conf/hive-site.xml
