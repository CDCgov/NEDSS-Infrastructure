#!/bin/bash

# Description:
# This script automates the collection of information prior to running
# terraform in the 
# installation directory through flags or prompts. Features include saving defaults,
# debug logging, step-by-step execution, a test mode, and preliminary access checks
# for AWS account. 

# Default values
#INSTALL_DIR=~/nbs_install
INFRA_VER=v1.2.25
# is this needed?
INSTALL_DIR_DEFAULT=~/nbs_install
DEFAULTS_FILE="nbs_defaults.sh"
#DEFAULTS_FILE=${INSTALL_DIR_DEFAULT}/nbs_defaults.sh
DEBUG=1
STEP=0
NOOP=0
PROMPT_CLASSIC=0
INPUTS_FILE_TEMPLATE=inputs.tfvars.tpl
NEW_INPUTS_FILE=inputs.tfvars

# Function to log debug messages
log_debug() {
    [[ $DEBUG_MODE -eq 1 ]] && echo "DEBUG: $*"
}

# Function to pause for step mode
step_pause() {
    [[ $STEP_MODE -eq 1 ]] && read -p "Press [Enter] key to continue..."
}

# Function for preliminary AWS access checks
preliminary_checks() {
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo "AWS access check failed. Ensure your AWS CLI is configured correctly."
        exit 1
    else
        log_debug "AWS access check passed."
    fi
}

#cd ${INSTALL_DIR}/terraform/aws/${TMP_SITE_NAME}
# cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${TMP_SITE_NAME}
# Load defaults if available
if [ -f "$DEFAULTS_FILE" ]; then
    source "$DEFAULTS_FILE"
else
    echo "${DEFAULTS_FILE} not found. Using script defaults."
fi

update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "${DEFAULTS_FILE}"; then
        #sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}


# Function to show usage
usage() {
    echo "Usage: $0 [-h] [-d INSTALL_DIR] [-c] [-g] [-s] [-t]"
    echo "  -h  Show this help message."
    echo "  -c  prompt for classic NBS6 values instead of assuming preexisting (default: ${PROMPT_CLASSIC})."
    echo "  -d  Specify installation directory (default: ${INSTALL_DIR_DEFAULT})."
    echo "  -g  Enable debug mode."
    echo "  -s  Enable step-by-step execution."
    echo "  -t  Test mode (no operations performed)."
    exit 1
}

execute_command() {
    local cmd=$1
    if [ $DEBUG -eq 1 ] || [ $NOOP -eq 1 ]; then
        echo "Command: $cmd"
    fi
    if [ $STEP -eq 1 ]; then
        read -p "Press enter to continue..."
    fi
    if [ $NOOP -eq 0 ]; then
        eval $cmd
    else
        echo "No-Op: Command not executed."
    fi
}


# Parse options
while getopts "hcd:gst" opt; do
    case ${opt} in
        h)
            usage
            ;;
        c)
            PROMPT_CLASSIC=1
            ;;
        d)
            INSTALL_DIR="$OPTARG"
            ;;
        g)
            DEBUG=1
            ;;
        s)
            STEP=1
            ;;
        t)
            NOOP=1
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            usage
            ;;
        :)
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Preliminary Access Checks
#if [ $NOOP -eq 0 ]; then
    if ! execute_command "aws sts get-caller-identity > /dev/null"; then
        echo "Error verifying AWS access."
        exit 1
    fi





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
if [ ${PROMPT_CLASSIC} -eq 0 ]
then
    # grab some stuff from existing environment
    echo "pick the existing vpc that contains the classic application server(vpc peering will be setup between this vpc and modern vpc)"
    LEGACY_VPC_ID=$(select_vpc)
    echo "pick classic private route table"
    PRIVATE_ROUTE_TABLE_ID=$(select_route_table)
    echo "pick classic public route table"
    PUBLIC_ROUTE_TABLE_ID=$(select_route_table)
    echo "pick the existing CIDR block that contains the classic application server(routing will be setup between this CIDR and modern CIDR)"
    LEGACY_CIDR_BLOCK=$(select_cidr $LEGACY_VPC_ID)
    echo "LEGACY_CIDR_BLOCK = $LEGACY_CIDR_BLOCK"
    echo "select second octet for legacy CIDR, this assumes a /16 etc"
    OCTET2b=$(select_subnet_octet)
    # this is legacy octet

else
    read -p "Please enter the classic octet value for new vpc 10.x.0.0/16: " OCTET2b
    read -p "need to prompt for other classic VPC info here, hit return to continue" junk
fi

echo "select an existing bucket for artifacts???"
BUCKET_NAME=$(select_s3_bucket)


# prompt for remaining info
#  SITE_NAME and EXAMPLE_DOMAIN_NAME
#  # OCTET2a, OCTET2b, OCTET2shared
# Prompts for additional information

read -p "Please enter the site name e.g. fts3 [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
update_defaults "SITE_NAME" "$SITE_NAME"
#read -p "Please enter the site name e.g. fts3: " SITE_NAME

read -p "Please enter the domain name e.g. nbspreview.com [${EXAMPLE_DOMAIN_NAME_DEFAULT}]: " EXAMPLE_DOMAIN_NAME && EXAMPLE_DOMAIN_NAME=${EXAMPLE_DOMAIN_NAME:-$EXAMPLE_DOMAIN_NAME_DEFAULT}
update_defaults "EXAMPLE_DOMAIN_NAME" "$EXAMPLE_DOMAIN_NAME"
#read -p "Please enter domain name  e.g. nbspreview.com : " EXAMPLE_DOMAIN_NAME

# OCTET2shared
read -p "Please enter the shared octet value for vpn access e.g. 3 will allow 10.3.0.0/16 [${OCTET2shared_DEFAULT}]: " OCTET2shared && OCTET2shared=${OCTET2shared:-$OCTET2shared_DEFAULT}
update_defaults "OCTET2shared" "$OCTET2shared"
#read -p "Please enter the shared octet value for vpn access e.g. 3 will allow 10.3.0.0/16: " OCTET2shared

# OCTET2a
read -p "Please enter the modern octet value for new vpc 10.x.0.0/16 [${OCTET2a_DEFAULT}]: " OCTET2a && OCTET2a=${OCTET2a:-$OCTET2a_DEFAULT}
update_defaults "OCTET2a" "$OCTET2a"
#read -p "Please enter the modern octet value for new vpc 10.x.0.0/16: " OCTET2a

TMP_ACCOUNT_ID=$(aws sts get-caller-identity | grep Arn | awk -F':' '{print $6}')
TMP_ROLE=$(aws sts get-caller-identity | grep Arn | awk -F':' '{print $7}' | awk -F'/' '{print $2}')


#INPUTS_FILE=inputs.tfvars
#NEW_INPUTS_FILE=inputs.tfvars.new
# Displaying the results

if [ ${PROMPT_CLASSIC} -eq 0 ]
then
    echo LEGACY_VPC_ID=${LEGACY_VPC_ID}
    echo PRIVATE_ROUTE_TABLE_ID=${PRIVATE_ROUTE_TABLE_ID}
    echo PUBLIC_ROUTE_TABLE_ID=${PUBLIC_ROUTE_TABLE_ID}
else
    read -p "need to save other values for classic VPC info here, hit return to continue" junk
fi


echo OCTET2a=${OCTET2a}
echo OCTET2b=${OCTET2b}
echo LEGACY_CIDR_BLOCK=${LEGACY_CIDR_BLOCK}
echo BUCKET_NAME=${BUCKET_NAME}
echo OCTET2shared=${OCTET2shared}
echo SITE_NAME=${SITE_NAME}
echo EXAMPLE_DOMAIN_NAME=${EXAMPLE_DOMAIN_NAME}
echo TMP_ACCOUNT_ID=${TMP_ACCOUNT_ID}
echo TMP_ROLE=${TMP_ROLE}

read -p "Hit return to update ${INPUTS_FILE}"

#cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${TMP_SITE_NAME}
cd ${INSTALL_DIR}/nbs-infrastructure-${INFRA_VER}/terraform/aws/${SITE_NAME}

if [ $DEBUG -eq 1 ] ; then
        echo "running cp -p ${INPUTS_FILE}  ${NEW_INPUTS_FILE} from `pwd`"
fi
if [ -f ${NEW_INPUTS_FILE} ]
then
    cp -p ${NEW_INPUTS_FILE}  ${NEW_INPUTS_FILE}.save
fi 

cp -p ${INPUTS_FILE_TEMPLATE}  ${NEW_INPUTS_FILE}

sed  --in-place "s/vpc-LEGACY-EXAMPLE/${LEGACY_VPC_ID}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/rtb-PRIVATE-EXAMPLE/${PRIVATE_ROUTE_TABLE_ID}/" ${NEW_INPUTS_FILE}
sed  --in-place "s/rtb-PUBLIC-EXAMPLE/${PUBLIC_ROUTE_TABLE_ID}/" ${NEW_INPUTS_FILE}
sed  --in-place "s/OCTET2a/${OCTET2a}/g"  ${NEW_INPUTS_FILE}
sed  --in-place "s/OCTET2b/${OCTET2b}/g"  ${NEW_INPUTS_FILE}
# use a different delimiter for CIDR"
sed  --in-place "s?EXAMPLE_LEGACY_CIDR_BLOCK?${LEGACY_CIDR_BLOCK}?" ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_BUCKET_NAME/${BUCKET_NAME}/"  ${NEW_INPUTS_FILE}
#sed  --in-place "s/EXAMPLE_OCTET2shared/${OCTET2shared}/g"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_ENVIRONMENT/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_SITE_NAME/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_DOMAIN_NAME/${EXAMPLE_DOMAIN_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_ACCOUNT_ID/${TMP_ACCOUNT_ID}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE/${TMP_ROLE}/"  ${NEW_INPUTS_FILE}
# we may want these the same throughout
sed  --in-place "s/EXAMPLE_RESOURCE_PREFIX/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE_ENVIRONMENT/${SITE_NAME}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE-fluentbit-bucket/${SITE_NAME}-fluentbit-bucket-${TMP_ACCOUNT_ID}/"  ${NEW_INPUTS_FILE}
sed  --in-place "s/EXAMPLE-fluentbit-logs/${SITE_NAME}-fluentbit-logs-${TMP_ACCOUNT_ID}/"  ${NEW_INPUTS_FILE}

exit 0
