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

