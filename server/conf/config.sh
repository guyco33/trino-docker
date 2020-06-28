#!/usr/bin/env bash

#function set_s3_accees_key {
#    file_name=$1
#    if [[ -n "${AWS_ACCESS_KEY_ID}" ]]
#    then
#        sed -i -e "s|%AWS_ACCESS_KEY%|${AWS_ACCESS_KEY_ID}|g" -e "s|%AWS_SECRET_KEY%|${AWS_SECRET_ACCESS_KEY}|g" ${file_name}
#    else
#        sed -i -e "/%AWS_ACCESS_KEY%/d" -e "/%AWS_SECRET_KEY%/d" ${file_name}
#    fi
#}

function set_gcs_credentials {
    file_name=$1
    if [[ -n "${GCS_PRIVATE_KEY_ID}" ]]
    then
        cp /opt/presto/etc/gcs_keyfile.template.json /opt/presto/etc/gcs_keyfile.json
        sed -i  -e "s|%GCS_ACCOUNT_EMAIL%|${GCS_ACCOUNT_EMAIL}|g" \
                -e "s|%ESCAPED_GCS_ACCOUNT_EMAIL%|$(echo $GCS_ACCOUNT_EMAIL | sed 's/@/%40/')|g" \
                -e "s|%GCS_PRIVATE_KEY_ID%|${GCS_PRIVATE_KEY_ID}|g" \
                -e "s|%GCS_PRIVATE_KEY%|$(echo $GCS_PRIVATE_KEY | sed 's/\\n/\\\\n/g')|g" \
                -e "s|%GCS_PROJECT_ID%|${GCS_PROJECT_ID}|g" \
                -e "s|%GCS_CLIENT_ID%|${GCS_CLIENT_ID}|g" \
                /opt/presto/etc/gcs_keyfile.json
        echo "hive.gcs.json-key-file-path=/opt/presto/etc/gcs_keyfile.json" >>${file_name}
        echo "hive.gcs.use-access-token=false" >>${file_name}
       fi
}

if [[ ${IS_COORDINATOR} == 'true' ]]
then
    cp /opt/presto/etc/config-coordinator.properties /opt/presto/etc/config.properties
    if [[ ${COORDINATOR_IS_WORKER} == 'true' ]]
    then
        sed -i -e "s|node-scheduler.include-coordinator=false|node-scheduler.include-coordinator=true|g" /opt/presto/etc/config.properties
    fi
else
    cp /opt/presto/etc/config-worker.properties /opt/presto/etc/config.properties
fi

cp /opt/presto/etc/hive.template.properties /opt/presto/etc/catalog/hive.properties

sed -i -e "s|%HIVE_SECURITY%|${HIVE_SECURITY}|g" \
       -e "s|%HMS_ADDRESS%|${HMS_ADDRESS}|g" \
       -e "s|%HMS_THRIFT_PORT%|${HMS_THRIFT_PORT}|g" \
        /opt/presto/etc/catalog/hive.properties
if [[ "${HIVE_SECURITY}" == "legacy" ]]
then
    echo "hive.allow-drop-table=true" >>/opt/presto/etc/catalog/hive.properties
    echo "hive.allow-rename-table=true" >>/opt/presto/etc/catalog/hive.properties
    echo "hive.allow-add-column=true" >>/opt/presto/etc/catalog/hive.properties
    echo "hive.allow-drop-column=true" >>/opt/presto/etc/catalog/hive.properties
    echo "hive.allow-rename-column=true" >>/opt/presto/etc/catalog/hive.properties
fi
#set_s3_accees_key /opt/presto/etc/catalog/hive.properties
set_gcs_credentials /opt/presto/etc/catalog/hive.properties

if [[ -n "${ICEBERG_DIR}" ]]
then
    cp /opt/presto/etc/iceberg.template.properties /opt/presto/etc/catalog/iceberg.properties
    sed -i -e "s|%ICEBERG_DIR%|${ICEBERG_DIR}|g" /opt/presto/etc/catalog/iceberg.properties
#    set_s3_accees_key /opt/presto/etc/catalog/iceberg.properties
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
#    set_s3_accees_key /opt/presto/etc/catalog/kinesis.properties
fi