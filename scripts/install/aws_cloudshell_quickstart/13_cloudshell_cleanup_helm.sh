#!/bin/bash
#
#
echo "what is the domain you will be using?"
read TMP_DOMAIN

#TMP_DOMAIN=site.example.com

echo "TMP_DOMAIN=${TMP_DOMAIN}"

remove_dns() 
{
  local TMP_HOST="$1"

  # Try to resolve the TMP_HOST to an IP address.
  local ip_address=$(dig +short "$TMP_HOST")

  # If the IP address is empty, the TMP_HOST does not resolve.
  if [[ ! -z "$ip_address" ]]; then
    echo "WARNING: now entry for $TMP_HOST is stale"
    #exit 1
  fi
  echo "manually remove dns entries for  ${TMP_HOST}"
}


# remove pods in reverse of install
echo "pods running"
kubectl get pods

echo "helm charts installed"
helm list
echo "removing nbs-gateway"
echo "hit return to continue"
read junk
helm uninstall nbs-gateway 

helm list
echo "removing nifi"
echo "hit return to continue"
read junk
helm uninstall nifi 

helm list
echo "removing modernization-api"
echo "hit return to continue"
read junk
helm uninstall modernization-api 

helm list
echo "removing page-builder-api"
echo "hit return to continue"
read junk
helm uninstall page-builder-api 
 
helm list
echo "removing elasticsearch"
echo "hit return to continue"
read junk
helm uninstall elasticsearch 

remove_dns app-classic.${TMP_DOMAIN};
remove_dns app.${TMP_DOMAIN};
remove_dns nifi.${TMP_DOMAIN};

# this will remove nlb and ingress routing 
helm list --namespace ingress-nginx        

echo "removing ingress-nginx"
echo "hit return to continue"
read junk
helm uninstall  --namespace ingress-nginx ingress-nginx

exit 0

