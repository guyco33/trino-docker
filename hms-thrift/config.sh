#!/usr/bin/env bash

if [[ -n "$AWS_ACCESS_KEY" ]]
then
    cp /opt/hive/conf/hive-site.s3-template.xml /opt/hive/conf/hive-site.xml
    sed -i  -e "s|%AWS_ACCESS_KEY%|${AWS_ACCESS_KEY}|g"  -e "s|%AWS_SECRET_KEY%|${AWS_SECRET_KEY}|g" /opt/hive/conf/hive-site.xml
else
    cp /opt/hive/conf/hive-site.template.xml /opt/hive/conf/hive-site.xml
fi
