#!/usr/bin/env bash

function set_gcs_credentials {
    file_name=$1
    if [[ -n "${GCS_PRIVATE_KEY_ID}" ]]
    then
        cp /opt/trino/etc/gcs_keyfile.template.json /opt/trino/etc/gcs_keyfile.json
        sed -i  -e "s|%GCS_ACCOUNT_EMAIL%|${GCS_ACCOUNT_EMAIL}|g" \
                -e "s|%ESCAPED_GCS_ACCOUNT_EMAIL%|$(echo $GCS_ACCOUNT_EMAIL | sed 's/@/%40/')|g" \
                -e "s|%GCS_PRIVATE_KEY_ID%|${GCS_PRIVATE_KEY_ID}|g" \
                -e "s|%GCS_PRIVATE_KEY%|$(echo $GCS_PRIVATE_KEY | sed 's/\\n/\\\\n/g')|g" \
                -e "s|%GCS_PROJECT_ID%|${GCS_PROJECT_ID}|g" \
                -e "s|%GCS_CLIENT_ID%|${GCS_CLIENT_ID}|g" \
                /opt/trino/etc/gcs_keyfile.json
        echo "hive.gcs.json-key-file-path=/opt/trino/etc/gcs_keyfile.json" >>${file_name}
        echo "hive.gcs.use-access-token=false" >>${file_name}
       fi
}

if [[ "${HIVE_SECURITY}" == "legacy" ]]
then
    echo "hive.allow-drop-table=true" >>/opt/trino/etc/catalog/hive.properties
    echo "hive.allow-rename-table=true" >>/opt/trino/etc/catalog/hive.properties
    echo "hive.allow-add-column=true" >>/opt/trino/etc/catalog/hive.properties
    echo "hive.allow-drop-column=true" >>/opt/trino/etc/catalog/hive.properties
    echo "hive.allow-rename-column=true" >>/opt/trino/etc/catalog/hive.properties
fi
set_gcs_credentials /opt/trino/etc/catalog/hive.properties
