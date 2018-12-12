#! /usr/bin/env bash
set -eu

IMAGE_ID=$1

# Get name for this image-id from aws
echo "Getting Name of this AMI"
IMAGE_NAME=$(aws ec2 describe-images --filters Name=image-id,Values="$IMAGE_ID" | jq --raw-output ".Images[0].Name")

# Copy the image to another region
SRC_REGION="eu-central-1"
DEST_REGION="eu-west-1"
echo "Copying AMI from $SRC_REGION to $DEST_REGION"
NEW_IMAGE_ID=$(aws ec2 copy-image --source-image-id "$IMAGE_ID" --source-region "$SRC_REGION" --region "$DEST_REGION" --name "$IMAGE_NAME" | jq --raw-output ".ImageId")


# wait until the copied image in the new region is marked as "available"
while true; do
	STATE=$(aws ec2 describe-images --filters Name=image-id,Values="$NEW_IMAGE_ID" --region=$DEST_REGION | jq --raw-output ".Images[0].State")
	if [ "$STATE" == "pending" ]; then
		echo "New image is still pending. Sleeping for 30 sec..."
		sleep 30
	elif [ "$STATE" == "available" ]; then
		echo "Image is available."
		break;
	else	
		echo "Image has an unknown state. Exiting"
		exit 1
	fi
done

# Make the image public in the new region
echo "Tagging new image as public"
aws ec2 modify-image-attribute --image-id "$NEW_IMAGE_ID" --region "$DEST_REGION" --launch-permission "{\"Add\":[{\"Group\":\"all\"}]}"


echo "Done. The new Image-ID is $NEW_IMAGE_ID"
