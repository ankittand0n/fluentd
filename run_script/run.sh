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
    * ) echo "Invalid choice. DELETING."; delete_cluster; create_cluster;;
  esac
else
  create_cluster
fi


# Install Helm
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update



# Install or upgrade Fluent Bit with custom values
helm upgrade --install fluent-bit fluent/fluent-bit --namespace logging -f fluent-bit-values.yaml

# Install or upgrade Loki with custom values
helm upgrade --install loki grafana/loki-stack --namespace logging -f loki-values.yaml

# Install or upgrade Grafana with custom values
helm upgrade --install grafana grafana/grafana --namespace logging -f grafana-values.yaml

helm upgrade --install httpd oci://registry-1.docker.io/bitnamicharts/apache --namespace logging
helm upgrade --install my-tomcat bitnami/tomcat --version 11.2.21 --namespace logging
helm upgrade --install my-redis bitnami/redis --version 20.1.7 --namespace logging

# Apply the Kubernetes manifest
# kubectl apply -f nginx-deployment.yaml

# Verify the installation
kubectl get pods -n logging

# Add a delay to ensure resources are created
echo "Waiting for resources to be created..."
sleep 30

# Wait for the pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=fluent-bit --namespace logging --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=loki --namespace logging --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --namespace logging --timeout=300s

# Set up port forwarding to access Grafana
GRAFANA_POD=$(kubectl get pods -n logging -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}")
nohup kubectl port-forward -n logging $GRAFANA_POD 3000:3000 > /dev/null 2>&1 &
# Set up port forwarding to access the Nginx service
# kubectl port-forward -n logging svc/nginx-service 8080:80

# Get the Grafana admin password
kubectl get secret --namespace logging grafana-admin-password -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

kubectl get secret --namespace logging grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
