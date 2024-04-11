#!/bin/bash

# This script helps in setting up an AWS environment for a specific site. It fetches AWS resources, prompts for various credentials,
# and applies these configurations to specific files. It is designed to facilitate the automation of cloud infrastructure setup
# and application deployment preparations.

# Default file for storing selected values and entered credentials
DEFAULTS_FILE="nbs_defaults.sh"

# Function to load saved defaults
load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
    fi
}

update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s/^${var_name}_DEFAULT=.*/${var_name}_DEFAULT=${var_value}/" "${DEFAULTS_FILE}"
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

#EFS_ID=$(aws efs describe-file-systems | jq -r '.FileSystems[0].FileSystemId')
#echo "EFS_ID=${EFS_ID}"


# Function to apply substitutions and copy files
apply_substitutions_and_copy() {
    local src_file_path=$1
    local dest_dir=$2
    local site_name=$3

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
    cp -ip "$src_file_path" "$new_file_path"

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
    sed -i "s/EXAMPLE_DOMAIN/${EXAMPLE_DOMAIN}/" "$new_file_path"
    sed -i "s/EXAMPLE_ACCOUNT_ID/${TMP_ACCOUNT_ID}/" "$new_file_path"
    sed -i "s/AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE/${TMP_ROLE}/" "$new_file_path"
    sed -i "s/EXAMPLE_RESOURCE_PREFIX/${SITE_NAME}/g" "$new_file_path"
    sed -i "s/EXAMPLE-fluentbit-bucket/${SITE_NAME}-fluentbit-bucket-${TMP_ACCOUNT_ID}/" "$new_file_path"
    sed -i "s/EXAMPLE_KC_PASSWORD8675309/${KEYCLOAK_ADMIN_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_KCDB_PASS8675309/${KEYCLOAK_DB_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_ENDPOINT/${DB_ENDPOINT}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_NAME/${DB_NAME}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_USER/${DB_USER}/" "$new_file_path"
    sed -i "s/EXAMPLE_DB_USER_PASSWORD/${DB_USER_PASSWORD}/" "$new_file_path"
    sed -i "s/MODERNIZATION_API_DB_USER/${MODERNIZATION_API_DB_USER}/" "$new_file_path"
    sed -i "s/MODERNIZATION_API_DB_USER_PASSWORD/${MODERNIZATION_API_DB_USER_PASSWORD}/" "$new_file_path"
    sed -i "s/EXAMPLE_EFS_ID/${EFS_ID}/" "$new_file_path"
    # Add more sed commands as needed for other placeholders
}


# Load saved defaults
load_defaults

# Start resource selection and prompts for credentials
#LEGACY_CIDR_BLOCK=$(select_cidr $LEGACY_VPC_ID)
#update_defaults "LEGACY_CIDR_BLOCK" "$LEGACY_CIDR_BLOCK"

select_db_endpoint;
update_defaults "DB_ENDPOINT" "$DB_ENDPOINT"

select_efs_volume; 
update_defaults "EFS_ID" "$EFS_ID"

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
update_defaults "DB_USER_PASSWORD" "$DB_USER_PASSWORD"

#read -p "Please enter the [${XXX_DEFAULT}]: " XXX && XXX=${XXX:-$XXX_DEFAULT}
#update_defaults "XXX" "$XXX"

#EXAMPLE_DB_NAME
#EXAMPLE_DB_USER
#EXAMPLE_DB_USER_PASSWORD

# Call the apply_substitutions_and_copy function for each required file
#apply_substitutions_and_copy "inputs.tfvars" "./" "$SITE_NAME"
apply_substitutions_and_copy "helm/k8-manifests/cluster-issuer-prod.yaml" "helm/k8-manifests" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/keycloak/values.yaml" "helm/charts/keycloak" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/elasticsearch-efs/values.yaml" "helm/charts/elasticsearch-efs" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/modernization-api/values.yaml" "helm/charts/modernization-api" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/nbs-gateway/values.yaml" "helm/charts/nbs-gateway" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/nginx-ingress/values.yaml" "helm/charts/nginx-ingress" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/nifi-efs/values.yaml" "helm/charts/nifi-efs" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/dataingestion-service/values.yaml" "helm/charts/dataingestion-service" "$SITE_NAME"
apply_substitutions_and_copy "helm/charts/page-builder-api/values.yaml" "helm/charts/page-builder-api" "$SITE_NAME"

echo "Configuration files have been updated and are ready for use."


