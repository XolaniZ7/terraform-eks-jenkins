Deploying EKS Cluster with Terraform.

Tools Used:
•	Jenkins: CI/CD automation server for orchestrating the pipeline.
•	Terraform: Infrastructure as Code tool for provisioning AWS resources like VPC, subnets, security groups, and EKS clusters.
•	Kubernetes (EKS): Container orchestration platform for deploying, managing, and scaling containerized applications.

Jenkins-server Terraform Configuration
•	Backend.tf: Specifies backend settings to store the Terraform state file in an S3 bucket for remote state management, essential for collaboration and infrastructure management.
•	Data.tf: Dynamically provisions AWS resources using the latest Amazon Linux 2 AMI and available AZs.
•	Jenkins-install.sh: EC2 user data script that installs Jenkins, git, Terraform, and kubectl when the server boots up.
•	Main.tf:
o	Creates a VPC with a specified CIDR block, availability zones, and public subnets.
o	Defines a security group for Jenkins with ingress rules allowing HTTP (port 8080) and SSH (port 22) from any IP, and egress rules allowing all outbound traffic.
o	Launches an EC2 instance for Jenkins, specifying instance type, key pair, security group, subnet, public IP, and user data script.
•	Terraform.tfvars: Configuration for deploying a VPC, subnets, and EC2 instance type for Jenkins.

EKS Terraform Configuration
VPC Module
•	Purpose: Sets up a VPC (jenkins-vpc) with public and private subnets suitable for hosting resources, particularly an EKS cluster.
•	Key Configurations:
o	Name and CIDR: Defines the VPC name and its CIDR block (var.vpc_cidr).
o	Availability Zones: Retrieves available AZs for subnet placement.
o	Subnets: Defines private and public subnets (var.private_subnets and var.public_subnets).
o	DNS Hostnames: Enables DNS hostnames within the VPC.
o	NAT Gateway: Configures a single NAT Gateway for private subnet internet access.

EKS Module
•	Purpose: Deploys an EKS cluster (my-eks-cluster) using the terraform-aws-modules/eks/aws module.
•	Key Configurations:
o	Cluster Endpoint Access: Enables public access to the EKS cluster endpoint.
o	Cluster Name and Version: Defines the EKS cluster name (my-eks-cluster) and version (1.29).
o	VPC and Subnets: Specifies the VPC ID (module.vpc.vpc_id) and subnet IDs (module.vpc.private_subnets) for the EKS cluster.
o	Managed Node Group: Sets up a managed node group (nodes) with specifications for instance types (t2.small), minimum (1), maximum (3), and desired (2) number of nodes.
ConfigurationFiles
Deployment.yaml - This Kubernetes YAML configuration defines a Deployment named nginx that manages a single instance of the NGINX web server container.
•	Deployment: Manages the lifecycle and scaling of the NGINX container.
o	Replicas: Specifies one replica, meaning one instance of the NGINX container will be running.
o	Selector: Defines how the Deployment selects which Pods to manage.
	MatchLabels: Matches Pods with the label app: nginx.
o	Template: Describes the Pods managed by the Deployment.
	Metadata: Sets the label app: nginx for Pods created by this Deployment.
	Spec: Specifies the configuration of the NGINX container within the Pod.
	Containers: Configures the NGINX container.
	Name: Specifies the name of the container as nginx.
	Image: Specifies the Docker image (nginx) used for the container.
	Ports: Specifies that the container listens on port 80.
Service.yaml - This Kubernetes YAML configuration defines a Service named nginx that exposes the NGINX deployment to the outside world using a LoadBalancer.
•	Service: Defines networking rules to access NGINX Pods (app: nginx).
o	Name: Specifies the name of the Service as nginx.
o	Labels: Adds the label app: nginx to the Service.
•	Spec:
o	Ports: Specifies that the Service listens on port 80 (http) and forwards traffic to targetPort 80 on the NGINX Pods using TCP protocol.
o	Selector: Routes traffic to Pods with the label app: nginx.
o	Type: Specifies the type of Service as LoadBalancer, allowing external traffic from outside the Kubernetes cluster to access NGINX.
Jenkins Installation Script:
This Bash script installs Jenkins, Git, Terraform, and kubectl on an Amazon Linux instance.
1.	Update System Packages:
bash
Copy code
suds yum update -y
2.	Install Jenkins:
bash
Copy code
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
3.	Install Git:
bash
Copy code
sudo yum install git -y
4.	Install Terraform:
bash
Copy code
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
5.	Install kubectl:
bash
Copy code
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mkdir -p $HOME/bin && sudo cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

Jenkins Filé
This Jenkins Declarative Pipeline script automates the deployment of an EKS cluster and the deployment of an NGINX application using Terraform and Kubernetes.
•	Pipeline Configuration:
o	Agent: Executes the pipeline on any available Jenkins agent.
o	Environment:
	Sets AWS credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) retrieved from Jenkins credentials.
	Specifies the AWS region (us-east-1) for deployment.
•	Stages:
o	Checkout SCM:
	Retrieves source code from a GitHub repository (https://github.com/XolaniZ7/terraform-eks-jenkins.git) on the main branch using Git SCM.
o	Initializing Terraform:
	Initializes Terraform in the EKS directory.
o	Formatting Terraform Code:
	Formats Terraform configuration files in the EKS directory.
o	Validating Terraform:
	Validates the syntax and configuration of Terraform files in the EKS directory.
o	Previewing the Infra using Terraform:
	Generates and displays an execution plan for Terraform changes in the EKS directory.
o	Creating/Destroying an EKS Cluster:
	Executes Terraform to create or destroy an EKS cluster ($action is a parameter indicating the action, such as apply or destroy, with --auto-approve for automatic approval).
o	Deploying Nginx Application:
	Updates the kubeconfig for the EKS cluster my-eks-cluster.
	Applies Kubernetes manifests (deployment.yaml and service.yaml) located in the EKS/ConfigurationFiles directory to deploy the NGINX application.






