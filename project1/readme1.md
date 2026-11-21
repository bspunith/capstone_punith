commands to install :
sudo apt install git -y
 
git --version
 
sudo apt install curl unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install
 
aws --version
 
sudo apt-get install -y gnupg software-properties-common
 
wget -O- https://apt.releases.hashicorp.com/gpg | \

gpg --dearmor | \

sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
 
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | \

sudo tee /etc/apt/sources.list.d/hashicorp.list
 
sudo apt update

sudo apt install terraform -y
 
terraform version
 
git --version

aws --version

terraform version
 
aws sts get-caller-identity 
 
region :ap-south-1
format : json

1. List All VPCs (Shows Default = True/False)
Shell
aws ec2 describe-vpcs \
--query 'Vpcs[*].[VpcId,CidrBlock,IsDefault]' \
--output table \
--region ap-south-1

2. List All Subnets and Their VPCs
Shell
aws ec2 describe-subnets \
--query 'Subnets[*].[SubnetId,VpcId,AvailabilityZone]' \
--output table \
--region ap-south-1

3. List All EC2 Instances
Shell
aws ec2 describe-instances \
--query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`]|[0].Value,PublicIpAddress]' \
--output table \
--region ap-south-1

4. Show Only Running Instances
Shell
aws ec2 describe-instances \
--filters Name=instance-state-name,Values=running \
--query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`]|[0].Value]' \
--output table \
--region ap-south-1
