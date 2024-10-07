#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to prompt the user for deployment
function prompt_deploy_demo_app() {
  read -p "Do you want to deploy the demo application? (yes/no): " choice
  case "$choice" in 
    yes|y|Y|YES ) return 0;;
    no|n|N|NO ) return 1;;
    * ) echo "Invalid choice. Exiting."; exit 1;;
  esac
}

# Prompt the user for deployment
if prompt_deploy_demo_app; then
  # Navigate to the demo directory
  cd demo

  # Build the Spring Boot application using Gradle
  echo "Building the Spring Boot application..."
  ./gradlew clean build

  # Build the Docker image
  echo "Building the Docker image..."
  docker build -t demo-app:latest .

  # Navigate back to the root directory
  cd ..

  # Load the Docker image into the kind cluster
  echo "Loading the Docker image into the kind cluster..."
  kind load docker-image demo-app:latest --name logging-cluster

  # Apply the Kubernetes deployment and service
  echo "Deploying the application to the Kubernetes cluster..."
  kubectl apply -f deployment.yaml --namespace logging

  # Wait for the deployment to be ready
  echo "Waiting for the deployment to be ready..."
  kubectl wait --for=condition=available deployment/demo-app --namespace logging --timeout=300s

  echo "The demo application has been deployed successfully."
else
  echo "Skipping the deployment of the demo application."
fi