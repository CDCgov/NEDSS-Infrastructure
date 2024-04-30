#!/bin/bash

# Initialize default values
DEBUG_MODE=0
STEP_MODE=0
TEST_MODE=0
RELEASE_VER=v7.4.0
INSTALL_DIR=nbs_install
SOURCE="github"  # Default to GitHub, other options are 's3' and 'local'

DEFAULTS_FILE="nbs_defaults.sh"

# Function to log debug messages
log_debug() {
    [[ $DEBUG_MODE -eq 1 ]] && echo "DEBUG: $*"
}

# Function to pause for step mode
step_pause() {
    [[ $STEP_MODE -eq 1 ]] && read -p "Press [Enter] key to continue..."
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

# Load saved defaults
load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        source "$DEFAULTS_FILE"
        log_debug "Loaded defaults from $DEFAULTS_FILE"
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
        \? ) echo "Usage: cmd [-d] [-s] [-i install_directory] [-r release_version] [-l] [-c copy_from_directory]"
             exit 1 ;;
    esac
done

load_defaults
step_pause

log_debug "Using INSTALL_DIR: $INSTALL_DIR"
log_debug "Using RELEASE_VER: $RELEASE_VER"
log_debug "Using SOURCE: $SOURCE"

INFRA_VER=v1.2.6
HELM_VER=v7.4.0

INFRA_FILE_BASE=nbs-infrastructure-${INFRA_VER}
HELM_FILE_BASE=nbs-helm-${HELM_VER}

#mkdir -p ~/${INSTALL_DIR}
#cd ~/${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

# Function to download and extract files
download_and_extract() {
    local file_base=$1
    local url=$2
    if [ -f ${file_base}.zip ]; then
        log_debug "${file_base}.zip exists, not downloading"
    else
        case $SOURCE in
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


