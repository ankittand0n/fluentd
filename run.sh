kind delete cluster --name logging-cluster

# Create a Kubernetes cluster using kind
kind create cluster --name logging-cluster

# Add Helm repositories
helm repo add elastic https://helm.elastic.co
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Create custom values file for Elasticsearch
# cat <<EOF > elasticsearch-values.yaml
# replicas: 1
# minimumMasterNodes: 1
# esJavaOpts: "-Xmx256m -Xms256m"
# resources:
#   requests:
#     cpu: "100m"
#     memory: "256Mi"
#   limits:
#     cpu: "200m"
#     memory: "512Mi"
# EOF

# Create the namespace if it doesn't exist
kubectl create namespace logging || true

# Set kubectl context to the kind cluster
kubectl config use-context kind-logging-cluster

# Install or upgrade Elasticsearch with custom values
# helm upgrade --install elasticsearch elastic/elasticsearch --namespace logging -f elasticsearch-values.yaml

helm  upgrade --install elasticsearch elastic/elasticsearch -n logging \
  --set replicas=1 \
  --set minimumMasterNodes=1 \
  --set resources.requests.memory=2Gi \
  --set resources.requests.cpu=1


# Create custom values file for Kibana with increased readiness probe timeout
# cat <<EOF > kibana-values.yaml
# elasticsearchHosts: "http://elasticsearch-master:9200"
# resources:
#   requests:
#     cpu: "50m"
#     memory: "128Mi"
#   limits:
#     cpu: "100m"
#     memory: "256Mi"
# readinessProbe:
#   httpGet:
#     path: /app/kibana
#     port: 5601
#   initialDelaySeconds: 60
#   timeoutSeconds: 30
# EOF

# Install or upgrade Kibana with custom values
# helm upgrade --install kibana elastic/kibana --namespace logging -f kibana-values.yaml

# Install or upgrade Kibana with default values
helm upgrade --install kibana elastic/kibana -n logging \
   --set elasticsearchHosts=http://elasticsearch-master:9200



# Create custom values file for Fluent Bit
cat <<EOF > fluent-bit-values.yaml
backend:
  type: es
  es:
    host: elasticsearch-master
    port: 9200
    logstash_prefix: "fluentbit"
    http_user: ""
    http_passwd: ""
resources:
  requests:
    cpu: "50m"
    memory: "128Mi"
  limits:
    cpu: "100m"
    memory: "256Mi"
EOF

# Install or upgrade Fluent Bit with custom values
helm upgrade --install fluent-bit fluent/fluent-bit --namespace logging -f fluent-bit-values.yaml

# Verify the installation
kubectl get pods -n logging

# Find the Kibana pod name
KIBANA_POD=$(kubectl get pods -n logging -l app=kibana -o jsonpath="{.items[0].metadata.name}")

# Set up port forwarding to access Kibana
kubectl port-forward -n logging $KIBANA_POD 5601:5601

# Describe the Elasticsearch pod for troubleshooting
# # Check the status of the Kibana pod
KIBANA_POD=$(kubectl get pods -n logging -l app=kibana -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod -n logging $KIBANA_POD

# Check the logs of the Kibana pod
kubectl logs -n logging $KIBANA_POD

# Check events in the logging namespace
kubectl get events -n logging --sort-by='.metadata.creationTimestamp'kubectl describe pod -n logging $(kubectl get pods -n logging -l app=elasticsearch -o jsonpath="{.items[0].metadata.name}")