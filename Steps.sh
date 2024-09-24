#!/bin/bash

# Define variables
NAMESPACE="default"
RELEASE_NAME="elasticsearch"
HELM_CHART="elastic/elasticsearch"
VALUES_FILE="values.yaml"

# Add the Helm repository for Elasticsearch
echo "Adding the Helm repository for Elasticsearch..."
helm repo add elastic https://helm.elastic.co
helm repo update

# Create a values file with resource adjustments
cat <<EOF > $VALUES_FILE
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1"

# Optional: Set Java heap size if needed
env:
  - name: ES_JAVA_OPTS
    value: "-Xms512m -Xmx512m"
EOF

# Install Elasticsearch with Helm
echo "Installing Elasticsearch..."
helm install $RELEASE_NAME $HELM_CHART --namespace $NAMESPACE --create-namespace -f $VALUES_FILE

# Verify installation
echo "Verifying Elasticsearch installation..."
kubectl get pods -l app=elasticsearch --namespace $NAMESPACE

# Check for persistent volume claims
echo "Checking Persistent Volume Claims..."
kubectl get pvc --namespace $NAMESPACE

# Check storage classes
echo "Checking Storage Classes..."
kubectl get storageclass

# Describe nodes for resource availability
echo "Describing nodes for resource availability..."
kubectl describe nodes

# Print cluster events for troubleshooting
echo "Checking cluster events for issues..."
kubectl get events --namespace $NAMESPACE

# Clean up values file
rm $VALUES_FILE

echo "Script completed. Review the output for any issues and adjust settings as necessary."
