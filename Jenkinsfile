pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
        KUBECONFIG = "${env.WORKSPACE}/.kube/config" // Explicitly set the KUBECONFIG path
    }
    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/gauri17-pro/terraform-jenkins-eks.git']])
                }
            }
        }
        stage('Initializing Terraform') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Formatting Terraform Code') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform fmt'
                    }
                }
            }
        }
        stage('Validating Terraform') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform validate'
                    }
                }
            }
        }
        stage('Previewing the Infra using Terraform') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform plan'
                    }
                    input(message: "Are you sure to proceed?", ok: "Proceed")
                }
            }
        }
        stage('Creating/Destroying an EKS Cluster') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform $action --auto-approve'
                    }
                }
            }
        }
        stage('Configure kubectl') {
            steps {
                script {
                    dir('EKS/ConfigurationFiles') {
                        // Ensure .kube directory exists
                        sh 'mkdir -p ~/.kube'
                        // Update kubeconfig
                        sh 'aws eks update-kubeconfig --name my-eks-cluster --kubeconfig ${KUBECONFIG}'
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    dir('EKS/ConfigurationFiles') {
                        // Apply Kubernetes configuration
                        sh 'kubectl apply -f deployment.yaml'
                    }
                }
            }
        }
    }
}
