# MERN_Terraform_Ansible

We are deploying a MERN application using Terraform and Ansible both.

Part 1: Infrastructure Setup with Terraform

1. AWS Setup and Terraform Initialization:

   - Configure AWS CLI and authenticate with your AWS account.

      Install the awscli on windows machine  from 
      ```
      https://awscli.amazonaws.com/AWSCLIV2-version.number.msi
      ```
      On Ubuntu from
      ```
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      sudo apt install unzip
      unzip awscliv2.zip
      sudo ./aws/install
      ```
      test it using "aws --version" if response is like below then aws is properly configured.
      
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/ce02d397-f7fc-4501-a746-52092ed7c228)
      

      Configure aws using the "aws configure" command before that We have to download the AWS Console access key.

      For that, go to My Security Credentials  ( Top right ) > choose Access keys > Create New Access Key, then download that key to the          local machine.
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/27c634e4-5db4-437a-8c2b-8ddcd7533b6a)

      ```
      aws configure
      ```
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/85d033ba-04ac-43a9-8541-eb6f86e28dfd)

      test it using  "aws sts get-caller-identity"
     
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/595d01c3-3bab-4e4d-8d19-bd0d623917a0)



   - Initialize a new Terraform project targeting AWS.
  
      Install Terraform on Windows using the below command
      ```
      choco install terraform
      ```
      Install Terraform on Ubuntu using the below command 
      ```
      sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
      ```
      Install the HashiCorp GPG key.
      ```
      wget -O- https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor | \
      sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
      ```
      Verify the key's fingerprint.
      ```
      gpg --no-default-keyring \
      --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      --fingerprint
      ```
      Add the official HashiCorp repository to your system.
      ```
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
      sudo tee /etc/apt/sources.list.d/hashicorp.list
      ```
      Download the package information from HashiCorp.
      ```
      sudo apt update
      ```
      Install Terraform from the new repository.
      ```
      sudo apt-get install terraform
      ```
      ```
         
      ```
      Test it using
      ```
      terraform -help
      ```
      Create a new directory for the project
      ```
      mkdir terraform-aws
      cd terraform-aws
      touch main.tf
      ```

3. VPC and Network Configuration:

   - Create an AWS VPC with two subnets: one public and one private.

   - Set up an Internet Gateway and a NAT Gateway.

   - Configure route tables for both subnets.






4. EC2 Instance Provisioning:

   - Launch two EC2 instances: one in the public subnet (for the web server) and another in the private subnet (for the database).

   - Ensure both instances are accessible via SSH (public instance only accessible from your IP).






5. Security Groups and IAM Roles:

   - Create necessary security groups for web and database servers.

   - Set up IAM roles for EC2 instances with required permissions.






6. Resource Output:

   - Output the public IP of the web server EC2 instance.
