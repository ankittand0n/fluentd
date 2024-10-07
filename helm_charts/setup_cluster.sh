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
