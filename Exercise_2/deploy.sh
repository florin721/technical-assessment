#!/bin/bash

DOCKER_IMAGE_NAME="florin721/rust_sample_app"  
DOCKER_IMAGE_TAG="latest"
EKS_NAMESPACE="opendelta" 
DEPLOYMENT_NAME="myapp-deployment"
CLUSTER_NAME="example-eks-cluster"


set -e

./manage_lb_target_group_attachment.sh

echo "Running Terraform init..."
terraform init -input=false

echo "Running Terraform plan..."
terraform plan -out=tfplan -input=false

echo "Running Terraform apply..."
terraform apply -input=false -auto-approve tfplan

./manage_lb_target_group_attachment.sh

echo "Running Terraform init..."
terraform init -input=false

echo "Running Terraform plan..."
terraform plan -out=tfplan -input=false

echo "Running Terraform apply..."
terraform apply -input=false -auto-approve tfplan

echo "Deploying to EKS cluster..."

aws eks update-kubeconfig --name ${CLUSTER_NAME}

# sed -i 's/client.authentication.k8s.io\/v1alpha1/client.authentication.k8s.io\/v1/g' ~/.kube/config

kubectl apply -f deploy.yaml

echo "Deployment complete! Your app should now be available on the EKS cluster."
