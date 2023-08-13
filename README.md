# AWS S3 Mount Point with Terraform
![architecture.png](images%2Farchitecture.png)
This project provides a proof-of-concept (POC) to mount an AWS S3 bucket into an EC2 instance using Terraform. It sets up the necessary components including VPC, S3 bucket, IAM policies, EC2 key pair, and the EC2 instance with Amazon Linux. The S3 bucket is then mounted into the EC2 instance.

## Prerequisites
* Terraform 1.5.4+ installed
* AWS CLI configured with appropriate access

## Resources Created
* **VPC with S3 Endpoint:** Network resources and endpoint for S3 access.
* **S3 Bucket:** The bucket to be mounted.
* **S3 Object:** A text file within the S3 bucket.
* **IAM Policies:** Required permissions for the EC2 instance to access the S3 bucket.
* **EC2 Key Pair:** Key pair used for EC2 instance.
* **EC2 Instance with Amazon Linux:** Instance where the S3 bucket will be mounted.

## Getting Started
Clone this repository and navigate into the project directory.

## Initialize Terraform
To download and initialize the necessary providers and modules, run:

```bash
terraform init
```

## Plan Your Changes
Review the changes before applying with:

```bash
terraform plan -out=plan.out
```
![tf_plan.png](images%2Ftf_plan.png)
## Apply the Changes
Apply the planned changes:

```bash
terraform apply plan.out
```
![tf_apply.png](images%2Ftf_apply.png)

## Information about EC2 instance
1. /mount_s3 is created when the EC2 instance boots the first time using UserData
2. The EC2 instance is set up to mount the S3 bucket at /mount_s3 directory.
3. Terraform places a test file in the S3 bucket - `s3_file.txt`.
4. EC2 instance profile allows permissions to S3 bucket and allows access connect with SSM.

## Testing
### Connect to the EC2 Instance with SSM
![ssm_connect.jpg](images%2Fssm_connect.jpg)

### Check file from the S3 bucket
```bash
sudo cat /mount_s3/s3_file.txt
```
![s3_file.png](images%2Fs3_file.png)

## Destroy the Resources to cleanup
When you're done experimenting, you can destroy all created resources with:

```bash
terraform destroy
```
![tf_destroy.png](images%2Ftf_destroy.png)

## Notes
* The EC2 instance is set up to mount the S3 bucket at /mount_s3 directory.
* Please ensure that you have the necessary permissions and access to perform these operations in AWS.