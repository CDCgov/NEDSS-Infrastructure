#!/bin/bash

# sample function, change to do the same for EFS_ids

select_vpc() {
    # Get the list of all existing VPC IDs with their Name tags
    mapfile -t vpcs < <(aws ec2 describe-vpcs --query 'Vpcs[].[VpcId, Tags[?Key==`Name`].Value | [0]]' --output text | awk '{print $1 " (" $2 ")"}')

    echo "Existing VPCs:"
    select vpc_option in "${vpcs[@]}" "Enter new VPC ID"; do
        if [ "$vpc_option" = "Enter new VPC ID" ]; then
            read -p "Please enter the new VPC ID: " custom_vpc
            legacy_vpc_id=$custom_vpc
        else
            # Extract the VPC ID from the selected option (which includes both ID and Name tag)
            legacy_vpc_id=$(echo $vpc_option | awk '{print $1}')
        fi
        break
    done

    echo "You've selected VPC ID: $legacy_vpc_id"
}

# Example usage
#select_vpc

EFS_ID=$(aws efs describe-file-systems | jq -r '.FileSystems[0].FileSystemId')
echo "EFS_ID=${EFS_ID}"

echo "manually add to appropriate helm chats, can automate later"
