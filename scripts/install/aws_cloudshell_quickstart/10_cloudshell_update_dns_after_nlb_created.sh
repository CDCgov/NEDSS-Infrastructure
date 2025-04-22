#!/bin/bash

# Script Description:
# This script automates the selection of an AWS Network Load Balancer (NLB) and manages Route53 DNS records.
# It performs checks to determine if a DNS record exists and if it points to the selected NLB, updating it if necessary.
# The script includes functionalities for debug logging, step-by-step execution, a test mode, and preliminary AWS access checks.
#
# Usage:
# ./scriptname [-d] [-s] [-t]
# -d: Enable debug logging for additional output.
# -s: Enable step mode to pause execution between steps.
# -t: Enable test mode to simulate changes without making actual AWS modifications.
#
# Ensure AWS CLI is configured with necessary permissions before running this script.

# define some functions used in lots of scripting, need to remove duplication
# log debug debug_message log_debug  pause_step load_defaults update_defaults resolve_secret prompt_for_value check_for_placeholders
source "$(dirname "$0")/../common_functions.sh"

# Initialize default values
DEFAULTS_FILE="`pwd`/nbs_defaults.sh"
DEBUG_MODE=0
STEP_MODE=0
TEST_MODE=0

# Function to log debug messages
#log_debug() {
#    [[ $DEBUG_MODE -eq 1 ]] && echo "DEBUG: $*"
#}

# Function to pause for step mode
#step_pause() {
#    [[ $STEP_MODE -eq 1 ]] && read -p "Press [Enter] key to continue..."
#}

# Function for preliminary AWS access checks
preliminary_checks() {
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo "AWS access check failed. Ensure your AWS CLI is configured correctly."
        exit 1
    else
        debug "AWS access check passed."
    fi
}

# Parse command-line options
while getopts "dst" opt; do
    case ${opt} in
        d ) DEBUG_MODE=1 ;;
        s ) STEP_MODE=1 ;;
        t ) TEST_MODE=1 ;;
        \? ) echo "Usage: $0 [-d] [-s] [-t]"
             exit 1 ;;
    esac
done

preliminary_checks
step_pause

# Load saved defaults
load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
        debug "Loaded defaults from $DEFAULTS_FILE"
    fi
}
load_defaults
step_pause

# Define additional functions and logic here...

# Function to manage Route53 DNS records
manage_dns_record() {
    local zone_id=$1
    local record_name=$2
    local nlb_dns_name=$3

    debug "Checking for existing DNS record: $record_name"
    existing_record=$(aws route53 list-resource-record-sets --hosted-zone-id "$zone_id" --query "ResourceRecordSets[?Name == '$record_name.']" --output json)

    if [[ -n "$existing_record" && $(echo "$existing_record" | jq -r '.[0].ResourceRecords[0].Value') != "$nlb_dns_name" ]]; then
        echo "DNS record exists but points to a different target. Updating record to point to $nlb_dns_name."
        if [[ $TEST_MODE -eq 0 ]]; then
            aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"$record_name\",\"Type\":\"CNAME\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$nlb_dns_name\"}]}}]}"
        else
            echo not running aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"$record_name\",\"Type\":\"CNAME\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$nlb_dns_name\"}]}}]}"
        fi
    elif [[ -z "$existing_record" ]]; then
        echo "DNS record does not exist. Creating record for $record_name to point to $nlb_dns_name."
        if [[ $TEST_MODE -eq 0 ]]; then
            aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{\"Changes\":[{\"Action\":\"CREATE\",\"ResourceRecordSet\":{\"Name\":\"$record_name\",\"Type\":\"CNAME\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$nlb_dns_name\"}]}}]}"
        else
            echo not running aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{\"Changes\":[{\"Action\":\"CREATE\",\"ResourceRecordSet\":{\"Name\":\"$record_name\",\"Type\":\"CNAME\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$nlb_dns_name\"}]}}]}"
        fi
    else
        echo "DNS record for $record_name already points to $nlb_dns_name."
    fi
}

# Function to update defaults file
update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}

# Function to select an NLB
select_nlb() {
    echo "Fetching NLBs..."
    #mapfile -t nlbs < <(aws elbv2 describe-load-balancers --type network --query 'LoadBalancers[].[LoadBalancerName, DNSName]' --output text)
    #mapfile -t nlbs < <(aws elbv2 describe-load-balancers --query 'LoadBalancers[].[LoadBalancerName, DNSName]' --output text)
    mapfile -t nlbs < <(aws elbv2 describe-load-balancers --query 'LoadBalancers[].[LoadBalancerName, DNSName]' --output text| grep -v alb)
    
    echo "Available NLBs:" > /dev/tty
    select nlb_option in "${nlbs[@]}"; do
        NLB_NAME=$(echo $nlb_option | awk '{print $1}')
        NLB_DNS_NAME=$(echo $nlb_option | awk '{print $2}')
        break
    done
    echo "Selected NLB: $NLB_NAME"
    echo "NLB DNS Name: $NLB_DNS_NAME"
}

# Function to select a Hosted Zone
select_hosted_zone() {
    echo "Fetching Hosted Zones..."
    #mapfile -t hosted_zones < <(aws route53 list-hosted-zones --query 'HostedZones[].[Name, Id]' --output text)
    mapfile -t hosted_zones < <(aws route53 list-hosted-zones --query 'HostedZones[].[Name, Id]' --output text | grep -v privat)
    
    echo "Available Hosted Zones:" > /dev/tty
    PS3="Please select a Hosted Zone: "
    select hosted_zone_option in "${hosted_zones[@]}"; do
        HOSTED_ZONE_NAME=$(echo $hosted_zone_option | awk '{print $1}')
        HOSTED_ZONE_ID=$(echo $hosted_zone_option | awk '{print $2}' | sed 's/\/hostedzone\///')
        break
    done
    echo "Selected Hosted Zone: $HOSTED_ZONE_NAME"
    echo "Hosted Zone ID: $HOSTED_ZONE_ID"
}

# Function to create Route53 DNS records
#create_route53_records() {
#    local zone_id=$1
#    local record_name=$2
#    local record_value=$3
#    
#    aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch '{
#        "Changes": [{
#            "Action": "UPSERT",
#            "ResourceRecordSet": {
#                "Name": "'$record_name'",
#                "Type": "CNAME",
#                "TTL": 300,
#                "ResourceRecords": [{"Value": "'$record_value'"}]
#            }
#        }]
#    }'
#    echo "Route53 record created for $record_name -> $record_value"
#}

# Load saved defaults
load_defaults

# Start resource selection
select_nlb
update_defaults "NLB_NAME" "$NLB_NAME"
update_defaults "NLB_DNS_NAME" "$NLB_DNS_NAME"

# Read necessary input from user
read -p "Please enter the site name [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
read -p "Please enter domain name [${EXAMPLE_DOMAIN_DEFAULT}]: " EXAMPLE_DOMAIN  && EXAMPLE_DOMAIN=${EXAMPLE_DOMAIN:-$EXAMPLE_DOMAIN_DEFAULT}
# Update defaults
update_defaults "SITE_NAME" "$SITE_NAME"
update_defaults "EXAMPLE_DOMAIN" "$EXAMPLE_DOMAIN"

select_hosted_zone
update_defaults "HOSTED_ZONE_NAME" "$HOSTED_ZONE_NAME"
update_defaults "HOSTED_ZONE_ID" "$HOSTED_ZONE_ID"

## Create DNS records for the subdomains
#create_route53_records "$HOSTED_ZONE_ID" "app.$SITE_NAME.$EXAMPLE_DOMAIN" "$NLB_DNS_NAME"
#create_route53_records "$HOSTED_ZONE_ID" "nifi.$SITE_NAME.$EXAMPLE_DOMAIN" "$NLB_DNS_NAME"
#create_route53_records "$HOSTED_ZONE_ID" "dataingestion.$SITE_NAME.$EXAMPLE_DOMAIN" "$NLB_DNS_NAME"

# Example usage of manage_dns_record function for app, nifi, dataingestion subdomains
#for subdomain in app nifi dataingestion; do
for subdomain in app nifi data dataingestion; do
    record_name="${subdomain}.${SITE_NAME}.${EXAMPLE_DOMAIN}"
    echo manage_dns_record "$HOSTED_ZONE_ID" "$record_name" "$NLB_DNS_NAME"
    step_pause
    manage_dns_record "$HOSTED_ZONE_ID" "$record_name" "$NLB_DNS_NAME"
    step_pause
done

echo "DNS management operation completed."

