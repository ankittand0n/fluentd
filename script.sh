#!/bin/bash

kubectl version --client
kubectl get nodes
kubectl create namespace logging


kubectl apply -f elasticsearch.yaml
kubectl apply -f kibana.yaml
kubectl apply -f services.yaml

# kubectl port-forward service/elasticsearch 9200:9200 -n logging
# kubectl port-forward service/kibana 5601:5601 -n logging

kubectl apply -f fluentd-configmap.yaml
kubectl apply -f fluentd-daemonset.yaml
echo '{"message": "Hello Fluentd!"}' | nc localhost 24224


# kubectl delete all --all --namespace default
helm install fluentd ./helm/fluentd/ --values ./helm/fluentd/values.yaml
helm install kibana ./helm/kibana/ --values ./helm/kibana/values.yaml
helm upgrade --install elasticsearch ./helm/elasticsearch --values ./helm/elasticsearch/values.yaml


helm upgrade --install fluentd ./helm/fluentd
helm upgrade --install kibana ./helm/kibana
helm upgrade --install elasticsearch ./helm/elasticsearch


