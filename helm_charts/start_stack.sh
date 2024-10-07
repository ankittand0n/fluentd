#!/bin/bash

# Add Helm repositories
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Deploy Fluent Bit
helm upgrade --install fluent-bit ./fluent-bit --namespace logging

# Deploy Loki.
helm upgrade --install loki ./loki --namespace logging

# Deploy Grafana
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
GRAFANA_POD=$(kubectl get pods -n logging -l app=grafana -o jsonpath="{.items[0].metadata.name}")
nohup kubectl port-forward -n logging $GRAFANA_POD 3000:3000 > /dev/null 2>&1 &

echo "The logging stack has been deployed successfully."
echo "Grafana is available at http://localhost:3000"
echo "Use the admin credentials to log in."
