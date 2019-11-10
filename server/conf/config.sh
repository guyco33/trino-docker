#!/usr/bin/env bash

function set_s3_accees_key {
    file_name=$1
    if [[ -n "$AWS_ACCESS_KEY" ]]
    then
        sed -i -e "s|%AWS_ACCESS_KEY%|${AWS_ACCESS_KEY}|g" -e "s|%AWS_SECRET_KEY%|${AWS_SECRET_KEY}|g" ${file_name}
    else
        sed -i -e "s|hive.s3.aws-access-key=%AWS_ACCESS_KEY%||g" -e "s|hive.s3.aws-secret-key=%AWS_SECRET_KEY%||g" ${file_name}
    fi
}

if [[ $IS_COORDINATOR == 'true' ]]
then
    cp /opt/presto/etc/config-coordinator.properties /opt/presto/etc/config.properties
    if [[ $COORDINATOR_IS_WORKER == 'true' ]]
    then
        sed -i -e "s|node-scheduler.include-coordinator=false|node-scheduler.include-coordinator=true|g" /opt/presto/etc/config.properties
    fi
else
    cp /opt/presto/etc/config-worker.properties /opt/presto/etc/config.properties
fi

cp /opt/presto/etc/catalog/hive.template.properties /opt/presto/etc/catalog/hive.properties
set_s3_accees_key /opt/presto/etc/catalog/hive.properties

if [[ -n "$ICEBERG_DIR" ]]
then
    cp /opt/presto/etc/catalog/iceberg.template.properties /opt/presto/etc/catalog/iceberg.properties
    sed -i -e "s|%ICEBERG_DIR%|${ICEBERG_DIR}|g" /opt/presto/etc/catalog/iceberg.properties
    set_s3_accees_key /opt/presto/etc/catalog/iceberg.properties
else
    rm -f /opt/presto/etc/catalog/iceberg.properties
fi
