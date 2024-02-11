# MERN_Terraform_Ansible

We are deploying a MERN application using Terraform and Ansible both.

Part 1: Infrastructure Setup with Terraform

1. AWS Setup and Terraform Initialization:

   - Configure AWS CLI and authenticate with your AWS account.

      Install the awscli on local machine  from 
      ```
      https://awscli.amazonaws.com/AWSCLIV2-version.number.msi
      ```
      test it using "aws --version" if response is like below then aws is properly configured.
      
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/ce02d397-f7fc-4501-a746-52092ed7c228)
      
      
      ```
      aws configure
      ```
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/85d033ba-04ac-43a9-8541-eb6f86e28dfd)

      test it using  "aws sts get-caller-identity"
     
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/595d01c3-3bab-4e4d-8d19-bd0d623917a0)



   - Initialize a new Terraform project targeting AWS.




2. VPC and Network Configuration:

   - Create an AWS VPC with two subnets: one public and one private.

   - Set up an Internet Gateway and a NAT Gateway.

   - Configure route tables for both subnets.






3. EC2 Instance Provisioning:

   - Launch two EC2 instances: one in the public subnet (for the web server) and another in the private subnet (for the database).

   - Ensure both instances are accessible via SSH (public instance only accessible from your IP).






4. Security Groups and IAM Roles:

   - Create necessary security groups for web and database servers.

   - Set up IAM roles for EC2 instances with required permissions.






5. Resource Output:

   - Output the public IP of the web server EC2 instance.
