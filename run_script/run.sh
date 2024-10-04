
# Delete Existing Kubernetes cluster using kind
kind delete cluster --name logging-cluster

# Create a Kubernetes cluster using kind
kind create cluster --name logging-cluster

kubectl config use-context kind-logging-cluster


# Install Helm
helm repo add elastic https://helm.elastic.co
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update


# Create the namespace if it doesn't exist
kubectl create namespace logging || true


# Install or upgrade Fluent Bit with custom values
helm upgrade --install fluent-bit fluent/fluent-bit --namespace logging -f fluent-bit-values.yaml

# Install or upgrade Loki with custom values
helm upgrade --install loki grafana/loki-stack --namespace logging -f loki-values.yaml

# Install or upgrade Grafana with custom values
helm upgrade --install grafana grafana/grafana --namespace logging -f grafana-values.yaml

# Apply the Kubernetes manifest
kubectl apply -f nginx-deployment.yaml

# Verify the installation
kubectl get pods -n logging

# Set up port forwarding to access Grafana
GRAFANA_POD=$(kubectl get pods -n logging -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n logging $GRAFANA_POD 3000:3000

# Set up port forwarding to access the Nginx service
kubectl port-forward -n logging svc/nginx-service 8080:80

# Get the Grafana admin password
kubectl get secret --namespace logging grafana-admin-password -o jsonpath="{.data.admin-password}" | base64 --decode ; echo