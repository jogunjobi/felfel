#!/bin/bash

# Start minikube
minikube start --force

# Enable ingress
minikube addons enable ingress

# Create Kubernetes objects
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod -l app=app

# Verify app is running
curl $(minikube ip)

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install Prometheus using Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus

# Configure Prometheus to scrape /metrics
kubectl port-forward deploy/prometheus-server 9090:9090 &
export POD_NAME=$(kubectl get pods -l "app=app" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 &
curl -X POST http://localhost:9090/-/reload

# View metrics in Prometheus UI
open http://localhost:9090