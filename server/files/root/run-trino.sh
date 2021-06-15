#!/bin/bash

set -xeuo pipefail

/root/setup.sh

set +e
grep -s -q 'node.id' /opt/trino/etc/node.properties
NODE_ID_EXISTS=$?
set -e

NODE_ID=""
if [[ ${NODE_ID_EXISTS} != 0 ]] ; then
    NODE_ID="-Dnode.id=${HOSTNAME}"
fi

if [[ "${IS_COORDINATOR}" == "true" ]]
then
    echo "discovery-server.enabled=true" >>/opt/trino/etc/config.properties
fi

exec /opt/trino/bin/launcher run ${NODE_ID} "$@"
