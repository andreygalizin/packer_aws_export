# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done
# Remove cloud-init to speed up the boot in virtualbox
sudo touch /etc/cloud/cloud-init.disabled
sudo apt remove cloud-init --yes
sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/

# Setup network in virtualbox
sudo rm /etc/netplan/50-cloud-init.yaml
sudo bash -c "cat > /etc/netplan/config.yaml" <<'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    id0:
      match:
        name: en*
      dhcp4: yes
EOF
sudo bash -c "echo '@reboot /usr/sbin/netplan apply' | crontab -"

export CUSTOM_AMI_NAME=your-ami-name
packer build example.pkr.hcl

AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=${CUSTOM_AMI_NAME}" | grep ImageId | cut -f4 -d'"')

aws ec2 export-image --image-id ${AMI_ID} --disk-image-format VMDK --s3-export-location S3Bucket=bucketname,S3Prefix=prefixname/

