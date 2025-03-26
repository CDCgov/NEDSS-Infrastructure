#!/bin/bash
# This script helps in setting up an AWS environment for a specific site. It fetches AWS resources, prompts for various credentials,
# and applies these configurations to specific files. It is designed to facilitate the automation of cloud infrastructure setup
# and application deployment preparations.

# Default settings
DEFAULTS_FILE="nbs_defaults.sh"
HELM_VER_DEFAULT=v7.9.0
NOOP=0
DEBUG=0
DEVELOPMENT=0
SEARCH_REPLACE=0
ZIP_FILES=0
NEW_FILES=()
SKIP_QUERY=0  # Added SKIP_QUERY to manage the bypassing of querying


# Usage function to display help

usage() {
    echo "Usage: $0 [options]"
    echo "  -h              Display this help message."
    echo "  -d              Enable debug mode."
    echo "  -D              Development mode for operations on non-production files."
    echo "  -s              Perform search and replace."
    # echo "  -n              Skip querying and updating variables, use defaults only."
    echo "  -z              Create a zip file of the modified files."
    exit 1
}

# Parse command-line options
#while getopts 'hdsDn?' OPTION; do
while getopts 'hdsD?z' OPTION; do
    case "$OPTION" in
        h)
            usage
            ;;
        d)
            DEBUG=1
            ;;
        D)
            DEVELOPMENT=1
            ;;
        s)
            SEARCH_REPLACE=1
            ;;
        #n)
        #    SKIP_QUERY=1  # Set SKIP_QUERY if the -n flag is used
        #    ;;
        z)
            ZIP_FILES=1
            ;;
        ?)
            usage
            ;;
    esac
done

if [ "${SEARCH_REPLACE}" -eq 1 ]
then
	echo "NOTICE: performing search and replace after prompts"
else
	echo "WARNING: not performing search and replace"
    echo "you will have to rerun to do actual search and replace in files"
    echo "script will save some selected values as defaults for next run"
    echo "cntl-c to exit and use -s flag next time, enter to continue"
    read junk
fi

# Debug function
debug() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "Debug: $1"
    fi
}

# Function to load saved defaults
load_defaults() {
    echo "NOTICE: reading previous values from $DEFAULTS_FILE"
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
    else
        echo "NOTICE: $DEFAULTS_FILE does not exist"
    fi
}

# Function to check AWS access and confirm account
check_aws_access() {
    local account_id=$(aws sts get-caller-identity --query "Account" --output text)
    local account_alias=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)
    if [ -z "$account_id" ]; then
        echo "Error verifying AWS access."
        exit 1
    else
        echo "You are currently accessing AWS Account ID: $account_id"
        # aws  iam list-account-aliases only works from organization owner
        # account
        #echo "Account Alias: $account_alias"
        echo "Account Alias: not available except from organization owner"
        read -p "Is this the intended AWS account? (y/n): " confirmation
        if [[ "$confirmation" != "y" ]]; then
            echo "AWS account verification failed. Exiting."
            exit 1
        fi
    fi
}

update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        #sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}


# Function to select a DB endpoint
select_db_endpoint() {
    echo "Fetching DB instances..."
    mapfile -t db_instances < <(aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,Endpoint.Address]' --output text)
    
    echo "Available DB Instances:" > /dev/tty
    select db_option in "${db_instances[@]}"; do
        DB_ENDPOINT=$(echo $db_option | awk '{print $NF}')
        break
    done
    echo "Selected DB Endpoint: $DB_ENDPOINT"
}

# select an EFS volume
select_efs_volume() {
    echo "Fetching EFS volumes..."
    mapfile -t efs_volumes < <(aws efs describe-file-systems --query 'FileSystems[].[FileSystemId]' --output text)
    
    echo "Available EFS Instances:" > /dev/tty
    select efs_option in "${efs_volumes[@]}"; do
        EFS_ID=$(echo $efs_option | awk '{print $NF}')
        break
    done
    echo "Selected EFS Volume: $EFS_ID"
}

# Function to select an MSK cluster and fetch its Kafka endpoint
select_msk_cluster() {
    echo "Fetching MSK clusters..."
    mapfile -t msk_clusters < <(aws kafka list-clusters --query 'ClusterInfoList[].[ClusterArn, ClusterName]' --output text)
    
    echo "Available MSK Clusters:" > /dev/tty
    select msk_option in "${msk_clusters[@]}"; do
        MSK_CLUSTER_ARN=$(echo $msk_option | awk '{print $1}') # Assuming ARN is the first column
        MSK_CLUSTER_NAME=$(echo $msk_option | awk '{print $2}') # Assuming Name is the second column
        break
    done
    echo "Selected MSK Cluster ARN: $MSK_CLUSTER_ARN"
    echo "Selected MSK Cluster Name: $MSK_CLUSTER_NAME"

    # Fetch the Kafka endpoint for the selected MSK cluster
    #MSK_KAFKA_ENDPOINT=$(aws kafka get-bootstrap-brokers --cluster-arn $MSK_CLUSTER_ARN --query 'BootstrapBrokerStringTls')
    MSK_KAFKA_ENDPOINT=$(aws kafka get-bootstrap-brokers --cluster-arn $MSK_CLUSTER_ARN --query 'BootstrapBrokerStringTls'| sed 's/"//g')
    echo "Selected MSK Kafka Endpoint: $MSK_KAFKA_ENDPOINT"
}



#EFS_ID=$(aws efs describe-file-systems | jq -r '.FileSystems[0].FileSystemId')
#echo "EFS_ID=${EFS_ID}"


# Function to apply substitutions and copy files
apply_substitutions_and_copy() {
    local src_file_path=$1
    local dest_dir=$2
    local site_name=$3

    debug "echo  src_file_path=$1 dest_dir=$2 site_name=$3"

    # Extract filename and extension
    local filename=$(basename -- "$src_file_path")
    local extension="${filename##*.}"
    filename="${filename%.*}"

    # New filename with SITE_NAME
    local new_filename="${filename}-${site_name}.${extension}"

    # Ensure destination directory exists
    mkdir -p "$dest_dir"

    # Full path for the new file
    local new_file_path="${dest_dir}/${new_filename}"

    # Copy and apply substitutions
    #echo cp -ip "$src_file_path" "$new_file_path"
    debug "echo creating $new_file_path"
    cp -ip "$src_file_path" "$new_file_path"

    if [ -f $new_file_path ]
    then
		NEW_FILES+=("$new_file_path")
	else
        echo "ERROR: $new_file_path not created"
        exit 1
    fi

    # Apply substitutions
    sed -i "s/vpc-LEGACY-EXAMPLE/${LEGACY_VPC_ID}/" "$new_file_path"
    sed -i "s/rtb-PRIVATE-EXAMPLE/${PRIVATE_ROUTE_TABLE_ID}/" "$new_file_path"
    sed -i "s/rtb-PUBLIC-EXAMPLE/${PUBLIC_ROUTE_TABLE_ID}/" "$new_file_path"
    sed -i "s/OCTET2a/${OCTET2a}/g" "$new_file_path"
    sed -i "s/OCTET2b/${OCTET2b}/g" "$new_file_path"
    sed -i "s?EXAMPLE_LEGACY_CIDR_BLOCK?${LEGACY_CIDR_BLOCK}?" "$new_file_path"
    sed -i "s/EXAMPLE_BUCKET_NAME/${BUCKET_NAME}/" "$new_file_path"
    sed -i "s/EXAMPLE_ENVIRONMENT/${SITE_NAME}/g" "$new_file_path"
    # TODO: FIXME: this needs to change in the template since
    # EXAMPLE_DOMAIN is used elsewhere
    sed -i "s/EXAMPLE_USER@EXAMPLE_DOMAIN/${CERT_MANAGER_EMAIL}/" "$new_file_path"
    #sed -i "s/EXAMPLE_DOMAIN/${EXAMPLE_DOMAIN}/" "$new_file_path"
    # TODO: FIXME: tweak helm charts to have more psi
    sed -i "s/EXAMPLE_DOMAIN/${SITE_NAME}.${EXAMPLE_DOMAIN}/" "$new_file_path"
    sed -i "s/EXAMPLE_ACCOUNT_ID/${TMP_ACCOUNT_ID}/" "$new_file_path"
    sed -i "s/AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE/${TMP_ROLE}/" "$new_file_path"
    sed -i "s/EXAMPLE_RESOURCE_PREFIX/${SITE_NAME}/g" "$new_file_path"
    sed -i "s/EXAMPLE-fluentbit-bucket/${SITE_NAME}-fluentbit-bucket-${TMP_ACCOUNT_ID}/" "$new_file_path"
    sed -i "s/EXAMPLE_KC_PASSWORD8675309/${KEYCLOAK_ADMIN_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_KCDB_PASS8675309/${KEYCLOAK_DB_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_ENDPOINT/${DB_ENDPOINT}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_NAME/${DB_NAME}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_USER_PASSWORD/${DB_USER_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_USER/${DB_USER}/" "$new_file_path"
    sed -i "s/MODERNIZATION_API_DB_USER_PASSWORD/${MODERNIZATION_API_DB_USER_PASSWORD}/" "$new_file_path"
    sed -i "s/MODERNIZATION_API_DB_USER/${MODERNIZATION_API_DB_USER}/" "$new_file_path"
    sed -i "s/EXAMPLE_EFS_ID/${EFS_ID}/" "$new_file_path"
    sed -i "s/EXAMPLE_NIFI_ADMIN_USER_PASSWORD/${NIFI_ADMIN_USER_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_NIFI_ADMIN_USER/${NIFI_ADMIN_USER}/" "$new_file_path"
    sed -i "s/EXAMPLE_NIFI_SENSITIVE_PROPS/${NIFI_SENSITIVE_PROPS}/" "$new_file_path"

    sed -i "s/EXAMPLE_MSK_KAFKA_ENDPOINT/${MSK_KAFKA_ENDPOINT}/" "$new_file_path"
    sed -i "s/EXAMPLE_SFTP_ENABLED/${SFTP_ENABLED}/" "$new_file_path"
    sed -i "s/EXAMPLE_SFTP_HOST/${SFTP_HOST}/" "$new_file_path"
    sed -i "s/EXAMPLE_SFTP_USER/${SFTP_USER}/" "$new_file_path"
    sed -i "s/EXAMPLE_SFTP_PASS/${SFTP_PASS}/" "$new_file_path"
    sed -i "s/EXAMPLE_NBS_AUTHUSER/${NBS_AUTHUSER}/" "$new_file_path"
    sed -i "s?EXAMPLE_TOKEN_SECRET?${TOKEN_SECRET}?" "$new_file_path"
    sed -i "s?EXAMPLE_PARAMETER_SECRET?${PARAMETER_SECRET}?" "$new_file_path"


    # Add more sed commands as needed for other placeholders
    #sed -i "s/EXAMPLE_XXX/${XXX}/" "$new_file_path"



}

zip_new_files() {
    local zip_file_name="helm_local_customizations_${SITE_NAME}.zip"
    echo "Zipping new files into ${zip_file_name}..."
    zip "$zip_file_name" "${NEW_FILES[@]}"  # Add all tracked new files to the zip
    echo "Files zipped successfully."
}




# Check AWS access and confirm account
check_aws_access;

# Load saved defaults
load_defaults;

# Start resource selection and prompts for credentials
#LEGACY_CIDR_BLOCK=$(select_cidr $LEGACY_VPC_ID)
#update_defaults "LEGACY_CIDR_BLOCK" "$LEGACY_CIDR_BLOCK"

# TODO: fix skip query flag, does not work because variable names in
# defautls file have _DEFAULT added!!!!
if [ "$SKIP_QUERY" -eq 0 ]; then
    select_db_endpoint;
    update_defaults "DB_ENDPOINT" "$DB_ENDPOINT"

    select_efs_volume; 
    update_defaults "EFS_ID" "$EFS_ID"

    select_msk_cluster;
    update_defaults "MSK_CLUSTER_ARN" "$MSK_CLUSTER_ARN"
    update_defaults "MSK_CLUSTER_NAME" "$MSK_CLUSTER_NAME"
    update_defaults "MSK_KAFKA_ENDPOINT" "$MSK_KAFKA_ENDPOINT"

    echo "generating secrets with openssl"
    TOKEN_SECRET=$(openssl rand -base64 64 | tr -d '\n')
    PARAMETER_SECRET=$(openssl rand -base64 32 | cut -c1-32) 
    update_defaults "TOKEN_SECRET" "$TOKEN_SECRET"
    update_defaults "PARAMETER_SECRET" "$PARAMETER_SECRET"

    # Prompt for missing values with defaults
    read -p "Please enter Helm version [${HELM_VER_DEFAULT}]: " input_helm_ver
    HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
    update_defaults HELM_VER $HELM_VER

    read -p "Please enter installation directory [${INSTALL_DIR_DEFAULT}]: " input_install_dir
    INSTALL_DIR=${input_install_dir:-$INSTALL_DIR_DEFAULT}
    update_defaults INSTALL_DIR $INSTALL_DIR


    # Prompts for additional information
    read -p "Please enter the site name e.g. fts3 [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
    # read -p "Enter Image Name [$IMAGE_NAME_DEFAULT]: " IMAGE_NAME && IMAGE_NAME=${IMAGE_NAME:-$IMAGE_NAME_DEFAULT}
    update_defaults "SITE_NAME" "$SITE_NAME"

    read -p "Please enter domain name e.g. nbspreview.com [${EXAMPLE_DOMAIN_DEFAULT}]: " EXAMPLE_DOMAIN  && EXAMPLE_DOMAIN=${EXAMPLE_DOMAIN:-$EXAMPLE_DOMAIN_DEFAULT}
    update_defaults "EXAMPLE_DOMAIN" "$EXAMPLE_DOMAIN"

    read -sp "Please enter the Keycloak admin password[${KEYCLOAK_ADMIN_PASSWORD_DEFAULT}]: " KEYCLOAK_ADMIN_PASSWORD && KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD:-$KEYCLOAK_ADMIN_PASSWORD_DEFAULT}
    echo
    update_defaults "KEYCLOAK_ADMIN_PASSWORD" "$KEYCLOAK_ADMIN_PASSWORD"

    read -sp "Please enter the Keycloak DB password[${KEYCLOAK_DB_PASSWORD_DEFAULT}]: " KEYCLOAK_DB_PASSWORD && KEYCLOAK_DB_PASSWORD=${KEYCLOAK_DB_PASSWORD:-$KEYCLOAK_DB_PASSWORD_DEFAULT}
    echo
    update_defaults "KEYCLOAK_DB_PASSWORD" "$KEYCLOAK_DB_PASSWORD"

    read -p "Please enter the modernization-api DB user[${MODERNIZATION_API_DB_USER_DEFAULT}]: " MODERNIZATION_API_DB_USER && MODERNIZATION_API_DB_USER=${MODERNIZATION_API_DB_USER:-$MODERNIZATION_API_DB_USER_DEFAULT}
    update_defaults "MODERNIZATION_API_DB_USER" "$MODERNIZATION_API_DB_USER"

    read -sp "Please enter the modernization-api DB user password[${MODERNIZATION_API_DB_USER_PASSWORD_DEFAULT}]: " MODERNIZATION_API_DB_USER_PASSWORD && MODERNIZATION_API_DB_USER_PASSWORD=${MODERNIZATION_API_DB_USER_PASSWORD:-$MODERNIZATION_API_DB_USER_PASSWORD_DEFAULT}
    echo
    update_defaults "MODERNIZATION_API_DB_USER_PASSWORD" "$MODERNIZATION_API_DB_USER_PASSWORD"

    read -p "Please enter the Cert-Manager email address[${CERT_MANAGER_EMAIL_DEFAULT}]: " CERT_MANAGER_EMAIL && CERT_MANAGER_EMAIL=${CERT_MANAGER_EMAIL:-$CERT_MANAGER_EMAIL_DEFAULT}
    update_defaults "CERT_MANAGER_EMAIL" "$CERT_MANAGER_EMAIL"

    read -p "Please enter the DB Name [${DB_NAME_DEFAULT}]: " DB_NAME && DB_NAME=${DB_NAME:-$DB_NAME_DEFAULT}
    update_defaults "DB_NAME" "$DB_NAME"

    read -p "Please enter the DB_USER [${DB_USER_DEFAULT}]: " DB_USER && DB_USER=${DB_USER:-$DB_USER_DEFAULT}
    update_defaults "DB_USER" "$DB_USER"

    read -sp "Please enter the DB_USER_PASSWORD[${DB_USER_PASSWORD_DEFAULT}]: " DB_USER_PASSWORD && DB_USER_PASSWORD=${DB_USER_PASSWORD:-$DB_USER_PASSWORD_DEFAULT}
    echo
    update_defaults "DB_USER_PASSWORD" "$DB_USER_PASSWORD"

	read -p "Please enter the NIFI_ADMIN_USER e.g. admin [${NIFI_ADMIN_USER_DEFAULT}]: " NIFI_ADMIN_USER && NIFI_ADMIN_USER=${NIFI_ADMIN_USER:-$NIFI_ADMIN_USER_DEFAULT}
	update_defaults "NIFI_ADMIN_USER" "$NIFI_ADMIN_USER"

	read -sp "Please enter the NIFI_ADMIN_USER_PASSWORD[${NIFI_ADMIN_USER_PASSWORD_DEFAULT}]: " NIFI_ADMIN_USER_PASSWORD && NIFI_ADMIN_USER_PASSWORD=${NIFI_ADMIN_USER_PASSWORD:-$NIFI_ADMIN_USER_PASSWORD_DEFAULT}
    echo
	update_defaults "NIFI_ADMIN_USER_PASSWORD" "$NIFI_ADMIN_USER_PASSWORD"

	read -p "Please enter the NIFI_SENSITIVE_PROPS[${NIFI_SENSITIVE_PROPS_DEFAULT}]: " NIFI_SENSITIVE_PROPS && NIFI_SENSITIVE_PROPS=${NIFI_SENSITIVE_PROPS:-$NIFI_SENSITIVE_PROPS_DEFAULT}
	update_defaults "NIFI_SENSITIVE_PROPS" "$NIFI_SENSITIVE_PROPS"

	read -p "Please enter the SFTP_ENABLED flag (enabled/disabled) [${SFTP_ENABLED_DEFAULT}]: " SFTP_ENABLED && SFTP_ENABLED=${SFTP_ENABLED:-$SFTP_ENABLED_DEFAULT}
	update_defaults "SFTP_ENABLED" "$SFTP_ENABLED"

	read -p "Please enter the SFTP_HOST [${SFTP_HOST_DEFAULT}]: " SFTP_HOST && SFTP_HOST=${SFTP_HOST:-$SFTP_HOST_DEFAULT}
	update_defaults "SFTP_HOST" "$SFTP_HOST"

	read -p "Please enter the SFTP_USER[${SFTP_USER_DEFAULT}]: " SFTP_USER && SFTP_USER=${SFTP_USER:-$SFTP_USER_DEFAULT}
	update_defaults "SFTP_USER" "$SFTP_USER"

	read -sp "Please enter the SFTP_PASSWORD [${SFTP_PASS_DEFAULT}]: " SFTP_PASS && SFTP_PASS=${SFTP_PASS:-$SFTP_PASS_DEFAULT}
    echo
	update_defaults "SFTP_PASS" "$SFTP_PASS"

	read -p "Please enter the NBS_AUTHUSER e.g. superuser [${NBS_AUTHUSER_DEFAULT}]: " NBS_AUTHUSER && NBS_AUTHUSER=${NBS_AUTHUSER:-$NBS_AUTHUSER_DEFAULT}
    echo
	update_defaults "NBS_AUTHUSER" "$NBS_AUTHUSER"


	#read -p "Please enter the XXX [${XXX_DEFAULT}]: " XXX && XXX=${XXX:-$XXX_DEFAULT}
	#update_defaults "XXX" "$XXX"


else
	echo "skipping update of variables"

fi

# Proceed with the rest of the script
HELM_DIR=${INSTALL_DIR}/nbs-helm-${HELM_VER}
debug HELM_DIR=${HELM_DIR};
debug INSTALL_DIR=${INSTALL_DIR};
debug INSTALL_DIR_DEFAULT=${INSTALL_DIR_DEFAULT};

echo
# Call the apply_substitutions_and_copy function for each required file
#apply_substitutions_and_copy "inputs.tfvars" "./" "$SITE_NAME"
if [ "${SEARCH_REPLACE}" -eq 1 ]
then

	echo "NOTICE: performing search and replace on released containers"
    
    debug HELM_DIR=${HELM_DIR};
    debug "apply_substitutions_and_copy ${HELM_DIR}/k8-manifests/cluster-issuer-prod.yaml ${HELM_DIR}/k8-manifests $SITE_NAME"
    debug "pwd=`pwd`"

	apply_substitutions_and_copy "${HELM_DIR}/k8-manifests/cluster-issuer-prod.yaml" "${HELM_DIR}/k8-manifests" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/keycloak/values.yaml" "${HELM_DIR}/charts/keycloak" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/elasticsearch-efs/values.yaml" "${HELM_DIR}/charts/elasticsearch-efs" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/modernization-api/values.yaml" "${HELM_DIR}/charts/modernization-api" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/nbs-gateway/values.yaml" "${HELM_DIR}/charts/nbs-gateway" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/nginx-ingress/values.yaml" "${HELM_DIR}/charts/nginx-ingress" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/nifi-efs/values.yaml" "${HELM_DIR}/charts/nifi-efs" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/dataingestion-service/values.yaml" "${HELM_DIR}/charts/dataingestion-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/data-processing-service/values.yaml" "${HELM_DIR}/charts/data-processing-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/page-builder-api/values.yaml" "${HELM_DIR}/charts/page-builder-api" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/liquibase/values.yaml" "${HELM_DIR}/charts/liquibase" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/investigation-reporting-service/values.yaml" "${HELM_DIR}/charts/investigation-reporting-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/ldfdata-reporting-service/values.yaml" "${HELM_DIR}/charts/ldfdata-reporting-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/nnd-service/values.yaml" "${HELM_DIR}/charts/nnd-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/observation-reporting-service/values.yaml" "${HELM_DIR}/charts/observation-reporting-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/organization-reporting-service/values.yaml" "${HELM_DIR}/charts/organization-reporting-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/person-reporting-service/values.yaml" "${HELM_DIR}/charts/person-reporting-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/post-processing-reporting-service/values.yaml" "${HELM_DIR}/charts/post-processing-reporting-service" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/kafka-connect-sink/values.yaml" "${HELM_DIR}/charts/kafka-connect-sink" "$SITE_NAME"
	apply_substitutions_and_copy "${HELM_DIR}/charts/debezium/values.yaml" "${HELM_DIR}/charts/debezium" "$SITE_NAME"

	if [ "$DEVELOPMENT" -eq 1 ]; then
		echo "running search and replace on development containers"
    	apply_substitutions_and_copy "${HELM_DIR}/charts/person-reporting-service/values.yaml" "${HELM_DIR}/charts/person-reporting-service" "$SITE_NAME"
    	apply_substitutions_and_copy "${HELM_DIR}/charts/organization-reporting-service/values.yaml" "${HELM_DIR}/charts/organization-reporting-service" "$SITE_NAME"
    	apply_substitutions_and_copy "${HELM_DIR}/charts/srte-data-service/values.yaml" "${HELM_DIR}/charts/srte-data-service" "$SITE_NAME"
	fi
    echo "NOTICE: Configuration files have been updated and are ready for use."
else
	echo "WARNING: not performing search and replace"

fi


# Final operations
if [ "$ZIP_FILES" -eq 1 ]; then
    zip_new_files
fi

echo 
echo "Configuration files have been updated and are ready for use."



####################################################################
