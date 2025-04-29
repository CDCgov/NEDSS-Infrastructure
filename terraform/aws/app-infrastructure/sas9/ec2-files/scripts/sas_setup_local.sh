#!/bin/bash
#
# this script can search and replace variables in all needed files 

# debug
#set -x

#SITE_NAME=$1
DEBUG=1
SITE_NAME=$1

PREFIX="/nbs/${SITE_NAME}"

# Set variables only if they are not already defined
BACKUP=${BACKUP:-true}
SYSPREP=${SYSPREP:-false}
REPLACE=${REPLACE:-true}
RUN_SQL=${RUN_SQL:-true}  # Control SQL execution (default: true)

# Default values if parameters are missing
DEFAULT_RDS_ENDPOINT="example-rds-endpoint"
DEFAULT_ODSE_DB_USER="nbs_ods"
DEFAULT_ODSE_DB_USER_PASSWORD="ods"
DEFAULT_RDB_DB_USER="nbs_rdb"
DEFAULT_RDB_DB_USER_PASSWORD="rdb"
DEFAULT_EXAMPLE_SAS_USERNAME="SAS"
DEFAULT_SAS_USER_PASSWORD="test"

# Ensure REPLACE is false if SYSPREP is true
if [[ "$SYSPREP" == "true" ]]; then
    REPLACE=false
fi

FILES="/etc/systemd/system/sas_spawner.env /home/SAS/.odbc.ini /etc/odbc.ini /home/SAS/.bashrc /home/SAS/update_config.sql /opt/wildfly-10.0.0.Final/nedssdomain/Nedss/report/autoexec.sas"

TMP_DATE=$(date +%F-%H-%M)

echo "running $0 at $(date)" > /tmp/$(basename $0).log.${TMP_DATE}

# Function to collect system information
collect_system_info() {
    # Fetch RDS endpoint from Parameter Store
    RDS_ENDPOINT=$(aws ssm get-parameter --name "$PREFIX/rds_endpoint" --query "Parameter.Value" --with-decryption --output text 2>/dev/null)

    # If RDS endpoint isn't found, try fetching it from AWS CLI
    if [[ -z "$RDS_ENDPOINT" ]]; then
        echo "rds_endpoint not found in Parameter Store, checking AWS RDS instances..."
        RDS_COUNT=$(aws rds describe-db-instances --query "length(DBInstances)" --output text 2>/dev/null)

        if [[ "$RDS_COUNT" -eq 1 ]]; then
            RDS_ENDPOINT=$(aws rds describe-db-instances --query "DBInstances[0].Endpoint.Address" --output text 2>/dev/null)
            echo "RDS endpoint found: $RDS_ENDPOINT"
        else
            echo "Error: More than one RDS instance found or unable to retrieve RDS instance."
            exit 1
        fi
    fi

    # Default RDS endpoint if all retrieval attempts fail
    RDS_ENDPOINT=${RDS_ENDPOINT:-$DEFAULT_RDS_ENDPOINT}
    echo "Final RDS_ENDPOINT=${RDS_ENDPOINT}"

    PRIVATE_IP=$(aws ec2 describe-instances --instance-id $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    echo "PRIVATE_IP=${PRIVATE_IP}"

    HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
    echo "HOSTNAME=${HOSTNAME}"

    ODSE_DB_USER=$(aws ssm get-parameter --name "$PREFIX/sql_username" --query "Parameter.Value" --output text 2>/dev/null)
    ODSE_DB_USER=${ODSE_DB_USER:-$DEFAULT_ODSE_DB_USER}
    echo "ODSE_DB_USER=${ODSE_DB_USER}"

    ODSE_DB_USER_PASSWORD=$(aws ssm get-parameter --name "$PREFIX/ODSE_DB_USER_PASSWORD" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
    ODSE_DB_USER_PASSWORD=${ODSE_DB_USER_PASSWORD:-$DEFAULT_ODSE_DB_USER_PASSWORD}
    echo "ODSE_DB_USER_PASSWORD retrieved"
    if [ $DEBUG ] 
    then
	echo "ODSE_DB_USER_PASSWORD=$ODSE_DB_USER_PASSWORD"
    fi

    RDB_DB_USER=$(aws ssm get-parameter --name "$PREFIX/sql_username" --query "Parameter.Value" --output text 2>/dev/null)
    RDB_DB_USER=${RDB_DB_USER:-$DEFAULT_RDB_DB_USER}
    echo "RDB_DB_USER=${RDB_DB_USER}"

    RDB_DB_USER_PASSWORD=$(aws ssm get-parameter --name "$PREFIX/RDB_DB_USER_PASSWORD" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
    RDB_DB_USER_PASSWORD=${RDB_DB_USER_PASSWORD:-$DEFAULT_RDB_DB_USER_PASSWORD}
    echo "RDB_DB_USER_PASSWORD retrieved"
    if [ $DEBUG ] 
    then
	echo "RDB_DB_USER_PASSWORD=$RDB_DB_USER_PASSWORD"
    fi

    EXAMPLE_SAS_USERNAME=$(aws ssm get-parameter --name "$PREFIX/example_sas_username" --query "Parameter.Value" --output text 2>/dev/null)
    EXAMPLE_SAS_USERNAME=${EXAMPLE_SAS_USERNAME:-$DEFAULT_EXAMPLE_SAS_USERNAME}
    echo "EXAMPLE_SAS_USERNAME=${EXAMPLE_SAS_USERNAME}"


    EXAMPLE_SAS_USERNAME=$(aws ssm get-parameter --name "$PREFIX/example_sas_username" --query "Parameter.Value" --output text 2>/dev/null)
    EXAMPLE_SAS_USERNAME=${EXAMPLE_SAS_USERNAME:-$DEFAULT_EXAMPLE_SAS_USERNAME}
    echo "EXAMPLE_SAS_USERNAME=${EXAMPLE_SAS_USERNAME}"

    SAS_USER_PASSWORD=$(aws ssm get-parameter --name "$PREFIX/SAS_USER_PASSWORD" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
    SAS_USER_PASSWORD=${SAS_USER_PASSWORD:-$DEFAULT_SAS_USER_PASSWORD}
    echo "SAS_USER_PASSWORD retrieved"
    if [ $DEBUG ] 
    then
	echo "SAS_USER_PASSWORD=$SAS_USER_PASSWORD"
    fi
}

# Function to rotate logs and reset shell history
rotate_logs_and_clear_history() {
    echo "Rotating logs and clearing shell history..."

    # Rotate logs
    for log_file in /var/log/messages /var/log/syslog /var/log/auth.log /var/log/secure /var/log/sas/*; do
        if [[ -f "$log_file" ]]; then
            mv "$log_file" "$log_file.$TMP_DATE"
            touch "$log_file"
            chmod 600 "$log_file"
        fi
    done

    # Reset shell history for key users
    for user in sas root ssm-user ec2-user; do
        home_dir=$(eval echo ~$user)
        if [[ -d "$home_dir" ]]; then
            echo "Clearing history for user: $user"
            cat /dev/null > "$home_dir/.bash_history"
            history -c
        fi
    done

    # Ensure history is cleared from memory
    export HISTSIZE=0
}

# Collect system info only if REPLACE is true
if [[ "$REPLACE" == "true" ]]; then
    collect_system_info
fi

# If SYSPREP is enabled, rotate logs and clear shell history
if [[ "$SYSPREP" == "true" ]]; then
    #rotate_logs_and_clear_history
    echo not runnning rotate_logs_and_clear_history
fi

for TMP_FILE in ${FILES}; do
    if [[ "$BACKUP" == "true" ]]; then
        echo "Backing up ${TMP_FILE}"
        cp -p "${TMP_FILE}" "${TMP_FILE}.${TMP_DATE}"
    fi

    echo "Restoring template file for ${TMP_FILE}"
    cp -p "${TMP_FILE}.template" "${TMP_FILE}"

    if [[ "$REPLACE" == "true" ]]; then
        echo "Replacing placeholders in ${TMP_FILE}"
        sed -i "s#<DB_ENDPOINT>#${RDS_ENDPOINT}#g" "${TMP_FILE}"
        sed -i "s#<PRIVATE_IP>#${PRIVATE_IP}#g" "${TMP_FILE}"
        sed -i "s#<HOSTNAME>#${HOSTNAME}#g" "${TMP_FILE}"
        sed -i "s#EXAMPLE_SAS_USERNAME#${EXAMPLE_SAS_USERNAME}#g" "${TMP_FILE}"
        sed -i "s#<<SAS_USER_PASSWORD>>#${SAS_USER_PASSWORD}#g" "${TMP_FILE}"
        sed -i "s#<ODSE_DB_USER>#${ODSE_DB_USER}#g" "${TMP_FILE}"
        sed -i "s#<<ODSE_DB_USER_PASSWORD>>#${ODSE_DB_USER_PASSWORD}#g" "${TMP_FILE}"
        sed -i "s#<RDB_DB_USER>#${RDB_DB_USER}#g" "${TMP_FILE}"
        sed -i "s#<<RDB_DB_USER_PASSWORD>>#${RDB_DB_USER_PASSWORD}#g" "${TMP_FILE}"
    else
        echo "Skipping placeholder replacements for ${TMP_FILE} (REPLACE=false)"
    fi
done

if [[ "$REPLACE" == "true" ]]; then
	# Execute SQL script if enabled
	if [[ "$RUN_SQL" == "true" ]]; then
    		echo "Executing SQL script... output in /tmp/sql.out.${TMP_DATE} "
    		sqlcmd -S "${RDS_ENDPOINT}" -U "$ODSE_DB_USER" -P "$ODSE_DB_USER_PASSWORD" -i "/home/SAS/update_config.sql" -C > /tmp/sql.out.${TMP_DATE} 2>&1
	else
    		echo "Skipping SQL execution (RUN_SQL=false)"
    		echo sqlcmd -S "${RDS_ENDPOINT}" -U "$ODSE_DB_USER" -P "$ODSE_DB_USER_PASSWORD" -i "/home/SAS/update_config.sql" -C
	fi

	echo "restart SAS service"
	#systemctl stop sas_spawner.service; systemctl daemon-reload; systemctl start sas_spawner.service; systemctl status sas_spawner.service
	systemctl stop sas_spawner.service; systemctl daemon-reload; systemctl start sas_spawner.service
fi
