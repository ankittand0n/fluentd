#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a kind cluster exists
function cluster_exists() {
  kind get clusters | grep -q "logging-cluster"
}

# Function to delete the existing cluster
function delete_cluster() {
  echo "Deleting existing kind cluster..."
  kind delete cluster --name logging-cluster
}

# Function to create a new cluster
function create_cluster() {
  kind create cluster --name logging-cluster
  
  echo "Setting the current context to the kind cluster"
  kubectl config use-context kind-logging-cluster

  echo "Create the logging namespace"
  kubectl create namespace logging
}

# Check if the cluster exists
if cluster_exists; then
  echo "A kind cluster named 'logging-cluster' already exists."
  read -p "Do you want to delete the existing cluster and create a new one? (y/n): " choice
  case "$choice" in 
    y|Y ) delete_cluster; create_cluster;;
    n|N ) echo "Using the existing cluster.";;
    * ) echo "Invalid choice. Exiting."; exit 1;;
  esac
else
  create_cluster
fi

# Add Helm repositories
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Deploy Fluent Bit
echo "Deploying Fluent Bit..."
helm upgrade --install fluent-bit ./fluent-bit --namespace logging

# Deploy Loki
echo "Deploying Loki..."
helm upgrade --install loki ./loki --namespace logging

# Deploy Grafana
echo "Deploying Grafana..."
helm upgrade --install grafana ./grafana --namespace logging

# Add a delay to ensure resources are created
echo "Waiting for resources to be created..."
sleep 30

# Wait for the pods to be ready
kubectl wait --for=condition=ready pod -l app=fluent-bit --namespace logging --timeout=300s
kubectl wait --for=condition=ready pod -l app=loki --namespace logging --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana --namespace logging --timeout=300s

# Get the Grafana admin password
# kubectl get secret --namespace logging grafana-admin-password -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Set up port forwarding for Grafana in the background
echo "Setting up port forwarding for Grafana..."
GRAFANA_POD=$(kubectl get pods -n logging -l app=grafana -o jsonpath="{.items[0].metadata.name}")
nohup kubectl port-forward -n logging $GRAFANA_POD 3000:3000 > /dev/null 2>&1 &

echo "The logging stack has been deployed successfully."
echo "Grafana is available at http://localhost:3000"
echo "Use the admin credentials to log in."

# Call the deploy-demo-app.sh script
echo "Calling deploy-demo-app.sh script..."
./deploy-demo-app.sh