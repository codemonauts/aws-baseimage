#!/bin/sh
echo "Describing the image: $1"
describe_image=$(aws ec2 describe-images --image-ids "$1") 
response=$(echo "$describe_image"| jq  .Images[].BlockDeviceMappings[].Ebs.SnapshotId | jq . -r | grep -v null)
echo "Deregister image"
aws ec2 deregister-image --image-id "$1"
for snapshot in $response; do 
    echo "Delete snapshot: $snapshot"
    aws ec2 delete-snapshot --snapshot-id "$snapshot"
done