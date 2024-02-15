# Deploying MERN application using Terraform

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
      Initialize Terraform
      ```
      terraform init
      ```
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/494aa40e-0bb0-49ae-acad-0a666bee4ba9)

      Preview Changes
      ```
      terraform plan
      ```
      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/f4cac74f-4d8a-4f81-a971-c6bab3d1d576)

      Apply Changes
      ```
      terraform apply
      ```
      ```
      # Creates and EC2 instance with the default security group
      
      terraform {
        required_providers {
          aws = {
            source = "hashicorp/aws"
            version = "5.32.1"
          }
        }
      }
      
      provider "aws" {
        region = "ap-south-1" 
      }
      
      # VPC and Network Configuration
      resource "aws_vpc" "main" {
        cidr_block = "172.31.0.0/16"
        enable_dns_support = true
        enable_dns_hostnames = true
      }
      
      resource "aws_subnet" "public" {
        vpc_id                  = aws_vpc.main.id
        cidr_block              = "172.31.32.0/20"
        availability_zone       = "ap-south-1a"  
        map_public_ip_on_launch = true
      }
      
      resource "aws_subnet" "private" {
        vpc_id                  = aws_vpc.main.id
        cidr_block              = "172.31.0.0/20"
        availability_zone       = "ap-south-1b"  
      }
      
      resource "aws_internet_gateway" "gw" {
        vpc_id = aws_vpc.main.id
      }
      
      
      resource "aws_route_table" "public" {
        vpc_id = aws_vpc.main.id
      
        route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.gw.id
        }
      }
      
      resource "aws_route_table" "private" {
        vpc_id = aws_vpc.main.id
      }
      
      resource "aws_route_table_association" "public" {
        subnet_id      = aws_subnet.public.id
        route_table_id = aws_route_table.public.id
      }
      
      resource "aws_route_table_association" "private" {
        subnet_id      = aws_subnet.private.id
        route_table_id = aws_route_table.private.id
      }
      
      
      
      # Security Group configuration
      
      resource "aws_security_group" "custom_security_group" {
        name = "adarsh_terraform"
        description = "Security group for adarsh_terraform instance"
        vpc_id      = aws_vpc.main.id
      
          ingress {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]  
        }
      
        ingress {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]  
        }
      
        egress {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      
      }
      
      resource "aws_security_group" "custom_security_group_database" {
        name = "adarsh_database_terraform"
        description = "Security group for adarsh_terraform database"
        vpc_id      = aws_vpc.main.id
      
        ingress {
          from_port   = 3306  # MySQL default port
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]  
        }
      
      }
      
      # Instances provisioning
      resource "aws_instance" "adarsh_terraform" {
        ami           = "ami-03f4878755434977f"
        instance_type = "t2.micro"
        subnet_id       = aws_subnet.public.id
        key_name        = "adarsh"  # Change to your key pair
        vpc_security_group_ids  = [aws_security_group.custom_security_group.id]
      #   vpc_security_group_ids = [aws_security_group.adarsh_terraform.id]  # Reference the existing security group
      
        tags = {
          Name = "adarsh_mern_terraform"
        }
      }
      
      resource "aws_instance" "adarsh_database" {
        ami           = "ami-03f4878755434977f"
        instance_type = "t2.micro"
        subnet_id       = aws_subnet.private.id
        key_name        = "adarsh"  # Change to your key pair
        vpc_security_group_ids  = [aws_security_group.custom_security_group_database.id]
      #   vpc_security_group_ids = [aws_security_group.adarsh_terraform.id]  # Reference the existing security group
      
        tags = {
          Name = "adarsh_database_terraform"
        }
      }
      
      # Creation of IAM policies
      
      data "aws_iam_policy_document" "loadbalancer" {
        statement {
          sid       = "Statement1"
          effect    = "Allow"
          actions   = [
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:Get*",
          ]
          resources = ["*"]
        }
      
        statement {
          sid       = "Statement2"
          effect    = "Allow"
          actions   = [
            "ec2:DescribeInstances",
            "ec2:DescribeClassicLinkInstances",
            "ec2:DescribeSecurityGroups",
          ]
          resources = ["*"]
        }
      
        statement {
          sid       = "Statement3"
          effect    = "Allow"
          actions   = ["arc-zonal-shift:GetManagedResource"]
          resources = ["arn:aws:elasticloadbalancing:*:*:loadbalancer/*"]
        }
      
        statement {
          sid       = "Statement4"
          effect    = "Allow"
          actions   = [
            "arc-zonal-shift:ListManagedResources",
            "arc-zonal-shift:ListZonalShifts",
          ]
          resources = ["*"]
        }
      }
      
      resource "aws_iam_policy" "loadbalancer_policy" {
        name   = "load_balancer_mern"
        policy = data.aws_iam_policy_document.loadbalancer.json
      }
      
      # Displaying the output
      output "adarsh_terraform_instance_ip" {
        value = aws_instance.adarsh_terraform.public_ip
      }
      
      output "adarsh_database_terraform_instance_ip" {
        value = aws_instance.adarsh_terraform.public_ip
      }
      ```
3. VPC and Network Configuration:

   - Create an AWS VPC with two subnets: one public and one private.
   
   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/56ae0986-ba1a-4f23-bde1-a27f1171797b)

   - Set up an Internet Gateway and a NAT Gateway.

   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/4a33c414-21ef-42b2-bb0a-b76d90172c5f)

   - Configure route tables for both subnets.
   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/e5a1f76f-518b-470e-a967-0f81afe5ff80)


4. EC2 Instance Provisioning:

   - Launch two EC2 instances: one in the public subnet (for the web server) and another in the private subnet (for the database).

   EC2 instance in Public subnet
   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/2c772f45-74dd-434d-bd87-9a21a38c0e3f)

   EC2 instance in a private subnet
   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/b102a522-ae56-47fb-986a-85f7496db8c5)

   - Ensure both instances are accessible via SSH (public instance only accessible from your IP).

   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/5d923660-7d5f-493e-9060-0688b2102a53)
   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/47e76795-aad2-47b0-b830-aa1d0cef77c4)


6. Security Groups and IAM Roles:

   - Create necessary security groups for web and database servers.

   - Set up IAM roles for EC2 instances with required permissions.

   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/d41ddab8-9a64-4fe7-90a9-1e8287c39006)



7. Resource Output:

   - Output the public IP of the web server EC2 instance.
   ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/1ba4f32d-3269-4a6a-b986-958299774d80)


# Deploying MERN application using Ansible


1. Ansible Configuration:

   - Configure Ansible to communicate with the AWS EC2 instances.

      Create ec2 instance t2.micro which will act as a control node of ansible from this particular       
      instance ansible will control all other instances.

      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/738b7421-ba54-4c75-89be-8d3b4ef3cdda)

      #Some activities are to be performed on Control node and some on the worker nodes
      Installing Ansible on Ubuntu

      Activities to be done on the Control node
      ```
      sudo apt update
      sudo apt install openssh-server
      sudo apt install software-properties-common
      sudo add-apt-repository --yes --update ppa:ansible/ansible
      sudo apt install ansible
      ansible --version
      ```
      ```
      cd  /etc/ansible/
      nano hosts
      #entry  the all worker node
      #create a group 
      
      [Demo]
      172.31.40.147 #private IP of the worker nodes
      ```
      ```
      # nano ansible.cfg
      # some basic default values...
      [default]
      
      inventory      = /etc/ansible/hosts
      #library        = /usr/share/my_modules/
      #module_utils   = /usr/share/my_module_utils/
      #remote_tmp     = ~/.ansible/tmp
      #local_tmp      = ~/.ansible/tmp
      #plugin_filters_cfg = /etc/ansible/plugin_filters.yml
      #forks          = 5
      #poll_interval  = 15
      sudo_user      = root
      #ask_sudo_pass = True
      #ask_pass      = True
      #transport      = smart
      remote_port    = 22
      #module_lang    = C
      #module_set_locale = False
      
      # uncomment this to disable SSH key host checking
      host_key_checking = False
      ```
     create a root passwd in all worker node using passwd root
     
      On Worker nodes
     ```
      #entry the sshd file
      nano /etc/ssh/sshd_config
      
      #LoginGraceTime 2m
      PermitRootLogin yes
      
      # To disable tunneled clear text passwords, change to no here!
      PasswordAuthentication yes
     ```
     Now on Control Plane
     ```
     ssh-keygen
     ssh-copy-id root@<private ip of workernode>
     ```
     After all the confirguration Lets test it.
     ```
     ansible all -m ping
     ```
     ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/a30ec6c2-742a-4a41-9200-5c0d68747764)

     ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/a111a714-f113-4e81-9174-0e4ec607fe17)



     

3. Web Server Setup:

   - Write an Ansible playbook to install Node.js and NPM on the web server.

   - Clone the MERN application repository and install dependencies.
  
      ```
      - hosts: Demo
        user: root
        gather_facts: 'yes'
        become: 'yes'
        tasks:
          - name: Update apt cache
            apt:
              update_cache: 'yes'
          - name: Ansible shell module multiple commands
            shell: 'curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -'
          - name: Install Node.js dependencies
            apt:
              name: '{{ item }}'
              state: present
            loop:
              - curl
              - software-properties-common
              - nodejs
              - wget
              - curl
          - name: Discard local modifications in the destination directory
            command: git reset --hard HEAD
            args:
              chdir: /home/ubuntu/mern/
            ignore_errors: yes
          - name: Clone MERN application repository
            git:
              repo: 'https://github.com/UnpredictablePrashant/TravelMemory.git'
              dest: /home/ubuntu/mern
          - name: Create .env file with MongoDB URI and port
            ansible.builtin.lineinfile:
              path: /home/ubuntu/mern/backend/.env
              line: MONGO_URI= 'mongodb+srv://prashantdey:prashantkrdey@prashantdey.00jtczg.mongodb.net/msmernsample'
              create: 'yes'
          - name: Add port to .env file
            ansible.builtin.lineinfile:
              path: /home/ubuntu/mern/backend/.env
              line: PORT=3000
              insertafter: MONGO_URI='ENTER_YOUR_MONGO_URL'
          - name: Install dependencies for MERN application backend
            command: npm install
            args:
              chdir: /home/ubuntu/mern/backend
          - name: Run the MERN application backend
            command: node index.js
      ```
     ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/fa7bfc36-3bbb-4a27-812b-a00cb824892c)

     ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/dcb79aa4-4fbc-40bb-87de-c9ef6d2de6c2)

      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/d4f14f9d-95c8-464d-9815-bb489af60e69)

      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/03ec61fc-bf4d-40e6-a7ad-939016899971)

      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/3d93f0cd-9367-4f4c-9711-b701c8d626df)

     


4. Database Server Setup:

   - Install and configure MongoDB on the database server using Ansible.

   - Secure the MongoDB instance and create necessary users and databases.

5. Application Deployment:

   - Configure environment variables and start the Node.js application.

   - Ensure the React frontend communicates with the Express backend.

6. Security Hardening:

   - Harden the security by configuring firewalls and security groups.

   - Implement additional security measures as needed (e.g., SSH key pairs, disabling root login).

    ```
    ---
      - name: Harden security of AWS EC2 instance
        hosts: localhost
        gather_facts: yes
        vars:
          region: 'ap-south-1'
        tasks:
          - name: Create security group
            ec2_group:
              name: my-security-group
              description: Security group for my EC2 instance
              vpc_id: vpc-0d162cc8011c8aef4
              region: 'ap-south-1'
              access_key: AKIAYS2NQZ3RGNLQPPEP
              secret_key: 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
              rules:
                - proto: tcp
                  from_port: 22
                  to_port: 22
                  cidr_ip: 0.0.0.0/0  # Restrict SSH access to specific IP ranges if possible
                - proto: tcp
                  from_port: 80
                  to_port: 80
                  cidr_ip: 0.0.0.0/0
                - proto: tcp
                  from_port: 3000
                  to_port: 3000
                  cidr_ip: 0.0.0.0/0
              state: present
    ```
 
     ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/26907d68-2e80-4ba0-9005-334e04e2961d)

     ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/dff6dfcf-066b-4359-9640-8b13bbdf0be6)

      ![image](https://github.com/AdarshIITDH/MERN_Terraform_Ansible/assets/60352729/3ba5826b-a27d-4b3a-9420-ed31515081d4)



