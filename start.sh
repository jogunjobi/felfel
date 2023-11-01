#!/bin/bash

# Build image
docker build -t app .

minikube start --forc

# Enable ingress
minikube addons enable ingress

# Load image into minikube
minikube image load app

# Apply Kubernetes YAML
kubectl apply -f k8s.yaml

# Deploy to Kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Port forward Prometheus
#kubectl port-forward svc/prometheus 9090:9090 &

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
kubectl annotate svc flask-service prometheus.io/scrape="true" prometheus.io/port="8080"