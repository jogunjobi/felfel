#!/bin/bash

# Build image
docker build -t app .

minikube start --force

# Enable ingress
minikube addons enable ingress

# Load image into minikube
minikube image load app


# Deploy to Kubernetes
sed -i.bak 's|\${IMAGE_VERSION}|my-app:v2|' deployment.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
kubectl annotate svc flask-service prometheus.io/scrape="true" prometheus.io/port="8080"

# Port forward Prometheus
#kubectl port-forward svc/prometheus 9090:9090 &