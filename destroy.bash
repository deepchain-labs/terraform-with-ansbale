cd terraform
# terraform init
# terraform validate

terraform destroy -auto-approve


# EC2 instance ID
# INSTANCE_ID="i-0242d03a10bc23960"

# # Maximum number of attempts
# MAX_ATTEMPTS=20

# # Sleep interval in seconds
# SLEEP_INTERVAL=10

# attempt=1

# while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
#     echo "Attempt $attempt: Checking EC2 instance status..."
    
#     # Check the instance status
#     aws configure set aws_access_key_id AKIAXVECGO5EQWPEO4GL && aws configure set aws_secret_access_key 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 && aws configure set default.region ap-south-1
#     status=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' --output text)
    
#     echo $status
    
#     if [ "$status" == "running" ]; then
#         echo "EC2 instance is now running!"
#         break
#     fi

#     echo "EC2 instance is not running yet. Retrying in $SLEEP_INTERVAL seconds..."
#     sleep "$SLEEP_INTERVAL"
#     ((attempt++))
# done

# if [ "$attempt" -gt "$MAX_ATTEMPTS" ]; then
#     echo "Timed out waiting for EC2 instance to be in running state."
# fi

# Proceed with further operations after the instance is running
# ... Your additional commands here ...
