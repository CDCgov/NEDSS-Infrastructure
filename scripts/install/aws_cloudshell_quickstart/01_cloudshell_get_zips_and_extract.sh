#!/bin/bash

# Initialize default values
DEBUG_MODE=0
STEP_MODE=0
TEST_MODE=0
RELEASE_VER=v7.9.1.1
INFRA_VER=v1.2.33
HELM_VER=v7.9.1.1
INSTALL_DIR=nbs_install
SOURCE="github"  # Default to GitHub, other options are 's3' and 'local'

DEFAULTS_FILE="`pwd`/nbs_defaults.sh"

# Function to log debug messages
log_debug() {
    [[ $DEBUG_MODE -eq 1 ]] && echo "DEBUG: $*"
}

# Function to pause for step mode
step_pause() {
    [[ $STEP_MODE -eq 1 ]] && read -p "Press [Enter] key to continue..."
}

# Load saved defaults
load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
        log_debug "Loaded defaults from $DEFAULTS_FILE"
    fi
}

# Function to update defaults file
update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "${DEFAULTS_FILE}"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "${DEFAULTS_FILE}"
    fi
}

# Parse command-line options
while getopts "dsi:r:lc:" opt; do
    case ${opt} in
        d ) DEBUG_MODE=1 ;;
        s ) STEP_MODE=1 ;;
        i ) INSTALL_DIR=${OPTARG} ;;
        r ) RELEASE_VER=${OPTARG} ;;
        l ) SOURCE="local" ;;
        c ) COPY_FROM_DIR=${OPTARG} ;;
        \? ) echo "Usage: cmd [-d] [-s] [-i install_directory] [-r release_version (e.g. v7.8.1) ] [-l] [-c copy_from_directory]"
             exit 1 ;;
    esac
done


# Function to download and extract files
download_and_extract() {
    local file_base=$1
    local url=$2
    if [ -s ${file_base}.zip ]; then
        log_debug "`pwd`/${file_base}.zip exists, not downloading"
    else
        log_debug "SOURCE=${SOURCE}"
        case ${SOURCE} in
            "s3")
                echo "Downloading from S3: ${url}"
                aws s3 cp ${url} ${file_base}.zip
                ;;
            "local")
                echo "Copying from local directory: $COPY_FROM_DIR/${file_base}.zip"
                cp $COPY_FROM_DIR/${file_base}.zip .
                ;;
            "github")
                echo "Downloading from GitHub: ${url}"
                wget -q ${url} -O ${file_base}.zip
                ;;
            "*")
                echo "Error: no match found for source"
                exit 1
                ;;
        esac
        step_pause
    fi

    if [ -d ${file_base} ]; then
        log_debug "${file_base} directory exists, not unzipping"
    else
        log_debug "Unzipping ${file_base}.zip"
        unzip -q ${file_base}.zip -d ${file_base}
        step_pause
    fi
}

load_defaults
step_pause

# Prompt for missing values with defaults
read -p "Please enter Helm version e.g. v7.8.1 [${HELM_VER_DEFAULT}]: " input_helm_ver
HELM_VER=${input_helm_ver:-$HELM_VER_DEFAULT}
update_defaults HELM_VER $HELM_VER

read -p "Please enter Infrastructure version e.g. v1.2.23 [${INFRA_VER_DEFAULT}]: " input_infra_ver
INFRA_VER=${input_infra_ver:-$INFRA_VER_DEFAULT}
update_defaults INFRA_VER $INFRA_VER

read -p "Please enter installation directory [${INSTALL_DIR_DEFAULT}]: " input_install_dir
INSTALL_DIR=${input_install_dir:-$INSTALL_DIR_DEFAULT}
update_defaults INSTALL_DIR $INSTALL_DIR

# Prompts for additional information
read -p "Please enter the site name e.g. fts3 [${SITE_NAME_DEFAULT}]: " SITE_NAME && SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
# read -p "Enter Image Name [$IMAGE_NAME_DEFAULT]: " IMAGE_NAME && IMAGE_NAME=${IMAGE_NAME:-$IMAGE_NAME_DEFAULT}
update_defaults "SITE_NAME" "$SITE_NAME"

log_debug "Using INSTALL_DIR: $INSTALL_DIR"
log_debug "Using RELEASE_VER: $RELEASE_VER"
log_debug "Using SOURCE: $SOURCE"

INFRA_FILE_BASE=nbs-infrastructure-${INFRA_VER}
HELM_FILE_BASE=nbs-helm-${HELM_VER}

#mkdir -p ~/${INSTALL_DIR}
#cd ~/${INSTALL_DIR}
log_debug "mkdir ${INSTALL_DIR}"
mkdir -p ${INSTALL_DIR}
log_debug "cd ${INSTALL_DIR}"
cd ${INSTALL_DIR}
# Define GitHub URLs
INFRA_URL="https://github.com/CDCgov/NEDSS-Infrastructure/releases/download/${RELEASE_VER}/${INFRA_FILE_BASE}.zip"
HELM_URL="https://github.com/CDCgov/NEDSS-Helm/releases/download/${RELEASE_VER}/${HELM_FILE_BASE}.zip"

# Execute file handling based on source type
download_and_extract $INFRA_FILE_BASE $INFRA_URL
download_and_extract $HELM_FILE_BASE $HELM_URL

update_defaults "INSTALL_DIR" "$INSTALL_DIR"
update_defaults "RELEASE_VER" "$RELEASE_VER"

echo "Installation setup complete. Please run subsequent scripts to complete the installation."
exit 0


