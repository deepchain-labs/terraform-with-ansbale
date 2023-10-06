#!/bin/bash

set -e
set -x

# ensure SSH agent has all keys
# ssh-add -A

# set up the infrastructure
cd terraform
terraform init
terraform validate

terraform apply -auto-approve

SERVER1_PUB_IP=$(terraform output -raw server_public_ip-2)

# # SERVER1_PUB_IP=45.120.115.246

sed "s|{{SERVER1_PUB_IP}}|${SERVER1_PUB_IP}|g" ../ansible/inventory.temp  > ../ansible/inventory.ini

# EC2 instance ID
INSTANCE_ID=$(terraform output -raw server_id)


cd ../ansible

# Maximum number of attempts
MAX_ATTEMPTS=20

# Sleep interval in seconds
SLEEP_INTERVAL=10

attempt=1

while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    echo "Attempt $attempt: Checking EC2 instance status..."

    # configure aws
    aws configure set aws_access_key_id <key_id> && aws configure set aws_secret_access_key <key_secret> && aws configure set default.region ap-south-1
   
    # Check the instance status
    status=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' --output text)
    
    if [ "$status" == "running" ]; then
        echo "EC2 instance is now running!"
        ansible-playbook -i inventory.ini  playbooks/setup.yml
        break
    fi

    echo "EC2 instance is not running yet. Retrying in $SLEEP_INTERVAL seconds..."
    sleep "$SLEEP_INTERVAL"
    ((attempt++))
done

if [ "$attempt" -gt "$MAX_ATTEMPTS" ]; then
    echo "Timed out waiting for EC2 instance to be in running state."
fi

# Proceed with further operations after the instance is running
# ... Your additional commands here ...


# # pull the instance information from Terraform, and run the Ansible playbook against it to configure
# TF_STATE=../terraform/terraform.tfstate ansible-playbook "--inventory-file=$(which terraform-inventory)" provision.yml

echo "Success!"

cd ../terraform
terraform output
