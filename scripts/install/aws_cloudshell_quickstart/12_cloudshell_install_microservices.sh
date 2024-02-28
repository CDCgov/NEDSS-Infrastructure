#!/bin/bash

# must edit with each release or prompt and save
HELM_VER=v1.0.0
echo "edit line 4 and comment out exit, then rerun"
exit 1
HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}

INSTALL_DIR=~/nbs_install
cd ${INSTALL_DIR}
# sleep between containers
SLEEP_TIME=60


#
echo "what is the domain you will be using?"
read TMP_DOMAIN

#TMP_DOMAIN=site.example.com

echo "TMP_DOMAIN=${TMP_DOMAIN}"

#check_dns()
#{
#	TMP_HOST=$1
#
#	echo "checking ${TMP_HOST}"
#
#	if ! host ${TMP_HOST} > /dev/null
#	then
#		echo "No ip for ${TMP_HOST}"
#	fi
#
#	#host ${TMP_HOST}
#	echo "hit return to continue"
#	read junk
#
#}

#
check_dns() 
{
  local TMP_HOST="$1"

   echo "checking ${TMP_HOST}"
  # Try to resolve the TMP_HOST to an IP address.
  local ip_address=$(dig +short "$TMP_HOST")

  # If the IP address is empty, the TMP_HOST does not resolve.
  if [[ -z "$ip_address" ]]; then
    echo "ERROR: $TMP_HOST does not resolve!!"
    exit 1
  fi
}



cd ${HELM_DIR}/charts

check_dns app-classic.${TMP_DOMAIN};
check_dns app.${TMP_DOMAIN};
check_dns nifi.${TMP_DOMAIN};

echo "installing elasticsearch"
echo "hit return to continue"
read junk
helm install elasticsearch -f ./elasticsearch-efs/values.yaml elasticsearch-efs 
echo "sleeping for ${SLEEP_TIME} seconds"
sleep ${SLEEP_TIME}


echo "installing page-builder-api"
echo "hit return to continue"
read junk
helm install page-builder-api -f ./page-builder-api/values.yaml page-builder-api
echo "sleeping for ${SLEEP_TIME} seconds"
sleep ${SLEEP_TIME}

echo "installing modernization-api"
echo "hit return to continue"
read junk
helm install modernization-api -f ./modernization-api/values.yaml modernization-api
echo "sleeping for ${SLEEP_TIME} seconds"
sleep ${SLEEP_TIME}

echo "installing nifi"
echo "hit return to continue"
read junk
helm install nifi -f ./nifi-efs/values.yaml nifi-efs
echo "sleeping for ${SLEEP_TIME} seconds"
sleep ${SLEEP_TIME}

echo "installing nbs-gateway"
echo "hit return to continue"
read junk
helm install nbs-gateway -f ./nbs-gateway/values.yaml nbs-gateway
echo "sleeping for ${SLEEP_TIME} seconds"
sleep ${SLEEP_TIME}

exit 0

