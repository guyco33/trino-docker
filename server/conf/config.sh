#!/usr/bin/env bash

function set_s3_accees_key {
    file_name=$1
    if [[ -n "${AWS_ACCESS_KEY_ID}" ]]
    then
        sed -i -e "s|%AWS_ACCESS_KEY%|${AWS_ACCESS_KEY_ID}|g" -e "s|%AWS_SECRET_KEY%|${AWS_SECRET_ACCESS_KEY}|g" ${file_name}
    else
        sed -i -e "/%AWS_ACCESS_KEY%/d" -e "/%AWS_SECRET_KEY%/d" ${file_name}
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

cp /opt/presto/etc/hive.template.properties /opt/presto/etc/catalog/hive.properties
set_s3_accees_key /opt/presto/etc/catalog/hive.properties

if [[ -n "${ICEBERG_DIR}" ]]
then
    cp /opt/presto/etc/iceberg.template.properties /opt/presto/etc/catalog/iceberg.properties
    sed -i -e "s|%ICEBERG_DIR%|${ICEBERG_DIR}|g" /opt/presto/etc/catalog/iceberg.properties
    set_s3_accees_key /opt/presto/etc/catalog/iceberg.properties
else
    rm -f /opt/presto/etc/catalog/iceberg.properties
fi

if [[ -z "${KINESIS_DIR}" ]] && [[ -d "/opt/presto/etc/kinesis" ]]
then
    KINESIS_DIR="/opt/presto/etc/kinesis"
fi
if [[ -n "${KINESIS_DIR}" ]]
then
    cp /opt/presto/etc/kinesis.template.properties /opt/presto/etc/catalog/kinesis.properties
    sed -i -e "s|%KINESIS_DIR%|${KINESIS_DIR}|g" /opt/presto/etc/catalog/kinesis.properties
    set_s3_accees_key /opt/presto/etc/catalog/kinesis.properties
fi