#!/bin/bash

select_vpc() {
    mapfile -t vpcs < <(aws ec2 describe-vpcs --query 'Vpcs[].[VpcId, Tags[?Key==`Name`].Value | [0]]' --output text | awk '{print $1 " (" $2 ")"}')
    
    echo "Existing VPCs:" > /dev/tty
    select vpc_option in "${vpcs[@]}" "Enter new VPC ID"; do
        if [ "$vpc_option" = "Enter new VPC ID" ]; then
            read -p "Please enter the new VPC ID: " custom_vpc
            echo $custom_vpc
        else
            echo $(echo $vpc_option | awk '{print $1}')
        fi
        break
    done
}

select_route_table() {
    mapfile -t route_tables < <(aws ec2 describe-route-tables --query 'RouteTables[].[RouteTableId, Tags[?Key==`Name`].Value | [0]]' --output text | awk '{print $1 " (" $2 ")"}')
    
    echo "Existing Route Tables:" > /dev/tty
    select rt_option in "${route_tables[@]}" "Enter new Route Table ID"; do
        if [ "$rt_option" = "Enter new Route Table ID" ]; then
            read -p "Please enter the new Route Table ID: " custom_rt
            echo $custom_rt
        else
            echo $(echo $rt_option | awk '{print $1}')
        fi
        break
    done
}

select_cidr() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: select_cidr <VPC_ID>"
        return
    fi

    local vpc_id=$1
    mapfile -t cidrs < <(aws ec2 describe-vpcs --vpc-ids "$vpc_id" --query 'Vpcs[].[CidrBlock]' --output text)

    echo "Available CIDR Blocks for VPC $vpc_id:" > /dev/tty
    select cidr_option in "${cidrs[@]}" "Enter new CIDR Block"; do
        if [ "$cidr_option" = "Enter new CIDR Block" ]; then
            read -p "Please enter the new CIDR Block: " custom_cidr
            echo $custom_cidr
        else
            echo $cidr_option
        fi
        break
    done
}

select_s3_bucket() {
    mapfile -t buckets < <(aws s3api list-buckets --query 'Buckets[*].Name' --output text | tr '\t' '\n')

    echo "Existing S3 Buckets:" > /dev/tty
    select bucket_option in "${buckets[@]}" "Enter new bucket name"; do
        if [ "$bucket_option" = "Enter new bucket name" ]; then
            read -p "Please enter the new bucket name: " custom_bucket
            echo $custom_bucket
        else
            echo $bucket_option
        fi
        break
    done
}

select_subnet_octet() {
    mapfile -t subnets < <(aws ec2 describe-subnets --query 'Subnets[*].CidrBlock' --output text | tr '\t' '\n')
    
    second_octets=($(for subnet in "${subnets[@]}"; do echo "$subnet" | cut -d'.' -f2; done | sort -nu))
    
    echo "Available second octets from the existing subnets' CIDR blocks:" > /dev/tty
    select octet_option in "${second_octets[@]}" "Manually enter an octet"; do
        if [ "$octet_option" = "Manually enter an octet" ]; then
            read -p "Please enter the new octet value: " custom_octet
            echo $custom_octet
        else
            echo ${octet_option:-${second_octets[0]}}
        fi
        break
    done
}



# Example calls and setting return results to appropriate variables
# grab some stuff from existing environment

echo "pick the existing vpc that contains the classic application server(vpc peering will be setup between this vpc and modern vpc)"

LEGACY_VPC_ID=$(select_vpc)
echo "pick private route table"
PRIVATE_ROUTE_TABLE_ID=$(select_route_table)
echo "pick public route table"
PUBLIC_ROUTE_TABLE_ID=$(select_route_table)

echo "pick the existing CIDR block that contains the classic application server(routing will be setup between this CIDR and modern CIDR)"
LEGACY_CIDR_BLOCK=$(select_cidr $LEGACY_VPC_ID)
echo "LEGACY_CIDR_BLOCK = $LEGACY_CIDR_BLOCK"
echo "select an existing bucket for artifacts???"
BUCKET_NAME=$(select_s3_bucket)
# this is legacy octet
echo "select second octet for legacy CIDR, this assumes a /16 etc"
OCTET2b=$(select_subnet_octet)

# prompt for remaining info
#  SITE_NAME and EXAMPLE_DOMAIN
#  # OCTET2a, OCTET2b, OCTET2shared

read -p "Please enter the site name e.g. fts3: " SITE_NAME

read -p "Please enter domain name  e.g. nbspreview.com : " EXAMPLE_DOMAIN
#read -p "Please enter the shared octet value for vpn access e.g. 3 will allow 10.3.0.0/16: " OCTET2shared
read -p "Please enter the modern octet value for new vpc 10.x.0.0/16: " OCTET2a

TMP_ACCOUNT_ID=$(aws sts get-caller-identity | grep Arn | awk -F':' '{print $6}')
TMP_ROLE=$(aws sts get-caller-identity | grep Arn | awk -F':' '{print $7}' | awk -F'/' '{print $2}')


INPUTS_FILE=inputs.tfvars
NEW_INPUTS_FILE=inputs.tfvars.new
# Displaying the results

echo LEGACY_VPC_ID=${LEGACY_VPC_ID}
echo PRIVATE_ROUTE_TABLE_ID=${PRIVATE_ROUTE_TABLE_ID}
echo PUBLIC_ROUTE_TABLE_ID=${PUBLIC_ROUTE_TABLE_ID}
echo OCTET2a=${OCTET2a}
echo OCTET2b=${OCTET2b}
echo LEGACY_CIDR_BLOCK=${LEGACY_CIDR_BLOCK}
echo BUCKET_NAME=${BUCKET_NAME}
echo OCTET2shared=${OCTET2shared}
echo SITE_NAME=${SITE_NAME}
echo EXAMPLE_DOMAIN=${EXAMPLE_DOMAIN}
echo TMP_ACCOUNT_ID=${TMP_ACCOUNT_ID}
echo TMP_ROLE=${TMP_ROLE}

read -p "Hit return to update ${INPUTS_FILE}"

cp -p ${INPUTS_FILE}  ${NEW_INPUTS_FILE}
sed  --in-place "s/vpc-LEGACY-EXAMPLE/${LEGACY_VPC_ID}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/rtb-PRIVATE-EXAMPLE/${PRIVATE_ROUTE_TABLE_ID}/" ${NEW_INPUTS_FILE}
sed  --in-place "s/rtb-PUBLIC-EXAMPLE/${PUBLIC_ROUTE_TABLE_ID}/" ${NEW_INPUTS_FILE}
sed  --in-place "s/OCTET2a/${OCTET2a}/g"  ${NEW_INPUTS_FILE}
sed  --in-place "s/OCTET2b/${OCTET2b}/g"  ${NEW_INPUTS_FILE}

# use a different delimiter for CIDR"
sed  --in-place "s?EXAMPLE_LEGACY_CIDR_BLOCK?${LEGACY_CIDR_BLOCK}?" ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_BUCKET_NAME/${BUCKET_NAME}/"  ${NEW_INPUTS_FILE}
#sed  --in-place "s/EXAMPLE_OCTET2shared/${OCTET2shared}/g"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE-ENVIRONMENT/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_DOMAIN/${EXAMPLE_DOMAIN}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_ACCOUNT_ID/${TMP_ACCOUNT_ID}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE/${TMP_ROLE}/"  ${NEW_INPUTS_FILE}
# we may want these the same throughout
sed  --in-place "s/EXAMPLE_RESOURCE_PREFIX/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_ENVIRONMENT/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE-fluentbit-bucket/${SITE_NAME}-fluentbit-bucket-${TMP_ACCOUNT_ID}/"  ${NEW_INPUTS_FILE}


exit 0
