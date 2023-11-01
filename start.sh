#!/bin/bash

# Build image
docker build -t app .

# Load image into minikube
minikube image load app

# Apply Kubernetes YAML
kubectl apply -f k8s.yaml

# Port forward Prometheus
kubectl port-forward svc/prometheus 9090:9090 &

# Configure Prometheus to scrape app metrics
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-monitor
spec:
  selector:
    matchLabels:
      app: counter
  endpoints:
  - port: metrics
    interval: 15s
EOF