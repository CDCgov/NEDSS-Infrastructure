#!/bin/bash

# $Header: /home/mossc/work/cdc_create_nbs6_keycloak_users/RCS/create_sql_and_keycloak_json_from_csv_for_new_users.sh,v 1.11 2024/11/21 20:34:08 mossc Exp mossc $

# Output Files
#sql_output="create_nbs6_users.sql"
#json_output="create_keycloak_users.json"

# initialize password to something 
TMP_PASSWORD=changeme8675309


# Usage function to display help
usage() {
    echo "Usage: $0 -p <password> -f <csv_filename>"
    echo "  -f <csv_filename>    Specify the input CSV file, format: email, firstname, lastname, userid, NO HEADER LINES!"
    echo "  -p <password>        initial password for all users, should require changing, STRONGLY encouraged to use this flag"
    echo "  -h                   Display this help message."
    echo "                       it will generate an sql file to import into ODSE database and a"
    echo "                       json file to import into keycloak nbs-users realm"
    exit 1
}

# Parse command-line arguments
while getopts ":f:p:h" opt; do
  case $opt in
    f)
      input_file="$OPTARG"
      ;;
    p)
      TMP_PASSWORD="$OPTARG"
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if the input file was provided
if [ -z "$input_file" ]; then
  echo "Error: CSV file not specified."
  usage
fi

# Check if the file exists
if [ ! -f "$input_file" ]; then
  echo "Error: File '$input_file' not found."
  exit 1
fi

# Input CSV file
#input_file="input.csv"
FILE_PREFIX=$(basename -s .csv ${input_file})
sql_output="${FILE_PREFIX}_create_nbs6_users.sql"
json_output="${FILE_PREFIX}_create_keycloak_users.json"


# SQL Header, Template, and Footer
sql_header=$(cat <<'EOF'
--  Ensures that a set of users exist with a specified permission set in the NBS6 database.
---------------------------------------------------------------------------------------------------
-- The name of the Permission Set to apply to the User
declare @permission     varchar(100) = 'Supervisor'

-- The Jurisdication to to apply the permission to.  ALL is a special value that NBS uses to assign permission to every Jurisdiction.
declare @jurisdiction   varchar(100) = 'ALL'

--  The default password applied to each user
declare @password       varchar(256)    = 'Passw0rd!';

--  verify the users by outputting which users will be created set @verify to 1
declare @verify         tinyint         = 1

--  performa a dry run of user creation where no users will be created in NBS6 however the Keycloak export will be generated
declare @dryrun         tinyint         = 0

---------------------------------------------------------------------------------------------------

declare @changedBy bigint = -1;
declare @changedOn datetime = getDate();


use [NBS_ODSE]

-- find the NBS Class
declare @class varchar(20);
select
    @class = config_value
from [nbs_configuration]
where config_key = 'NBS_CLASS_CODE'

declare @next_id bigint
declare @current_user bigint

declare @users table (
    [username]          varchar (100),
    [first]             varchar (100),
    [last]              varchar (100),
    [email]             varchar (255),
    [permission_set]    varchar (100),
    [permission_scope]  varchar (100)
)

---------------------------------------------------------------------------------------------------
--  The users to add into NBS6 along with the default permission set and scope that will define their permissions
insert into @users ([username], [first], [last],[email], [permission_set], [permission_scope])
values
EOF
)

sql_footer=$(cat <<'EOF'
---------------------------------------------------------------------------------------------------
if( @verify = 1) begin
    select
        [new].[username],
        [new].[first] + ' ' + [new].[last] as [name],
        [new].[email]
    from @users as [new]
        left join Auth_user [existing] on
                [existing].user_id = [new].[username]
    where [existing].user_id is null
end

declare users cursor fast_forward read_only for
select
    [new].[username],
    [new].[first],
    [new].[last],
    [new].[permission_set],
    [new].[permission_scope]
from @users as [new]
        left join Auth_user [existing] on
                [existing].user_id = [new].[username]
    where   @dryrun = 0
        and [existing].user_id is null

declare @username           varchar (256)
declare @first              varchar (100)
declare @last               varchar (100)
declare @permission_set     varchar (100)
declare @permission_scope   varchar (100)


open users
fetch next from users into
    @username,
    @first,
    @last,
    @permission_set,
    @permission_scope

while @@FETCH_STATUS = 0
begin

    ---------------------------------------------------------------------------------------------------
    begin transaction
        --  get the next NBS identifier
        select
            @next_id = seed_value_nbr
        from local_uid_generator
        where class_name_cd = @class

        --  Add the user
        insert into Auth_user (
            nedss_entry_id,
            user_id,
            user_type,
            user_first_nm,
            user_last_nm,
            master_sec_admin_ind,
            prog_area_admin_ind,
            user_comments,
            add_user_id,
            add_time,
            last_chg_user_id,
            last_chg_time,
            record_status_cd,
            record_status_time
        ) values (
            @next_id,
            @username,
            'internalUser',
            @first,
            @last,
            'F',
            'F',
            'Auto-generated STLT user.',
            @changedBy,
            @changedOn,
            @changedBy,
            @changedOn,
            'ACTIVE',
            @changedOn
        )

        -- update NBS identifier
        update local_uid_generator
            set seed_value_nbr = @next_id + 1
        where class_name_cd = @class

        commit transaction

        select @current_user = @@identity

        -- Apply the permissions to the provided scope
        ;with jurisdictions ([name]) as (
        select
            [jurisdiction].code
        from NBS_SRTE..Jurisdiction_code [jurisdiction]
        union
        select
            'ALL'
        )
        insert into Auth_user_role (
            auth_user_uid,
            auth_role_nm,
            prog_area_cd,
            jurisdiction_cd,
            auth_perm_set_uid,
            role_guest_ind,
            read_only_ind,
            disp_seq_nbr,
            add_time,
            add_user_id,
            last_chg_time,
            last_chg_user_id,
            record_status_cd,
            record_status_time
        )
        select
            @current_user                       as [auth_user_uid],
            [permission_set].perm_set_nm        as [auth_role_nm],
            [program_area].[prog_area_cd],
            [jurisdiction].[name]               as [jurisdiction_cd],
            [permission_set].auth_perm_set_uid,
            'F'                                 as [role_guest_ind],
            'T'                                 as [read_only_ind],
            0                                   as [disp_seq_nbr],
            @changedOn                          as [add_time],
            @changedBy                          as [add_user_id],
            @changedOn                          as [last_chg_time],
            @changedBy                          as [last_chg_user_id],
            'ACTIVE'                            as [record_status_cd],
            @changedOn                          as [record_status_time]
        from Auth_perm_set [permission_set],
            jurisdictions [jurisdiction],
            NBS_SRTE..Program_area_code [program_area]

        where   [permission_set].perm_set_nm    = @permission_set
        and     [jurisdiction].[name]           = @permission_scope

        --  next user
        fetch next from users into
            @username,
            @first,
            @last,
            @permission_set,
            @permission_scope

        end

--  Clean up cursor resources
close users
deallocate users

--  Create a partial import for Keycloak

select
    [username],
    'true'          as [enabled],
    [email],
    DATEDIFF(SECOND,'1970-01-01', @changedOn)        as [createdTimestamp],
    (
        select
            'password'  as [type],
            @password   as [value]

        for json path
    ) as [credentials]

from @users
for json path, root('users')
;
EOF
)

sql_template=$(cat <<'EOF'
    ('TMP_USERNAME', 'TMP_FIRSTNAME','TMP_LASTNAME', 'TMP_EMAIL', @permission , @jurisdiction)
EOF
)

# JSON Header, Template, and Footer
json_header=$(cat <<'EOF'
{
  "users": [
EOF
)

json_footer=$(cat <<'EOF'
  ]
}
EOF
)

json_template=$(cat <<'EOF'
    {
      "id": "TMP_USERNAME",
      "username": "TMP_USERNAME",
      "firstName": "TMP_FIRSTNAME",
      "lastName": "TMP_LASTNAME",
      "emailVerified": false,
      "enabled": true,
      "totp": false,
      "credentials": [
        {
          "type": "password",
          "value": "TMP_PASSWORD",
          "temporary": false
        }
      ],
      "disableableCredentialTypes": [],
      "requiredActions": [],
      "notBefore": 0,
      "groups": []
    }
EOF
)


# Create or empty the output files
echo "$sql_header" > "$sql_output"
echo "$json_header" > "$json_output"

# tail -n +1 "$input_file" | while IFS=',' read -r email first_name last_name username
# Read CSV and replace placeholders, deal with dos formatted files/lines
# with CR/LF
tail -n +1 "$input_file" | tr -d '\r' | while IFS=',' read -r email first_name last_name username
do
  # Trim any leading/trailing whitespace
  email=$(echo "$email" | xargs)
  first_name=$(echo "$first_name" | xargs)
  last_name=$(echo "$last_name" | xargs)
  username=$(echo "$username" | xargs)

  # Replace placeholders in SQL
  sql_entry=${sql_template//TMP_USERNAME/$username}
  sql_entry=${sql_entry//TMP_FIRSTNAME/$first_name}
  sql_entry=${sql_entry//TMP_LASTNAME/$last_name}
  sql_entry=${sql_entry//TMP_EMAIL/$email}

  # Replace placeholders in JSON
  json_entry=${json_template//TMP_USERNAME/$username}
  json_entry=${json_entry//TMP_FIRSTNAME/$first_name}
  json_entry=${json_entry//TMP_LASTNAME/$last_name}
  json_entry=${json_entry//TMP_EMAIL/$email}
  json_entry=${json_entry//TMP_PASSWORD/$TMP_PASSWORD}

  # Append entries to the output files
  echo "$sql_entry", >> "$sql_output"
  echo "  $json_entry," >> "$json_output"
done

# Determine if GNU sed or BSD sed is being used
# macs require an argument to -i flag
#if sed --version >/dev/null 2>&1; then
#  SED_CMD="sed -i"
#else
#  SED_CMD="sed -i ''"
#fi


# Remove the last trailing comma from JSON file
# - Process the input file with `sed` to remove the trailing comma on the
# last line
# - Redirect the output to a temporary file
# - Replace the original file with the temporary file
# macs require an argument to -i flag so we do not use in-place to make it
# cross platform use of sed
sed '$ s/,$//' "$json_output" > "${json_output}.tmp" && mv "${json_output}.tmp" "$json_output"

# Remove the last trailing comma from SQL file
# - Same logic as above but applied to the SQL output file
sed '$ s/,$//' "$sql_output" > "${sql_output}.tmp" && mv "${sql_output}.tmp" "$sql_output"


# append the JSON footer
echo "$json_footer" >> "$json_output"

# append the SQL footer
echo "$sql_footer" >> "$sql_output"

echo "${sql_output} and ${json_output} files have been created."

# 
# $Log: create_sql_and_keycloak_json_from_csv_for_new_users.sh,v $
# Revision 1.11  2024/11/21 20:34:08  mossc
# used a temp file so we did not need extra logic for sed version
#
# Revision 1.10  2024/11/21 19:23:30  mossc
# added logic to detect non-gnu sed
#
# Revision 1.9  2024/11/20 19:04:17  mossc
# added conversion of dos format 
# CSVs and initialize the tmp password
#
# Revision 1.8  2024/11/19 20:51:23  mossc
# fixed order of usage
#
# Revision 1.7  2024/11/05 20:49:17  mossc
# added comments
# in usage
#
# Revision 1.6  2024/11/05 20:44:06  mossc
# added password argument and fixed logic for multiple sql users
#
# Revision 1.5  2024/11/05 20:38:59  mossc
# build output based on input csv basename
#
# Revision 1.4  2024/11/05 20:02:14  mossc
# changed credentials, removed ids and timestamps from template
#
#

