#!/bin/bash
# export CUSTOM_AMI_NAME=your-ami-name
export CUSTOM_AMI_NAME=sher-ami
# packer build build-aws-ami.pkr.hcl

AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=${CUSTOM_AMI_NAME}" | grep ImageId | cut -f4 -d'"')

aws ec2 export-image --image-id ${AMI_ID} --disk-image-format VMDK --s3-export-location S3Bucket=bucketname,S3Prefix=prefixname/
