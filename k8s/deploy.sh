#!/bin/bash

# Shopping App Kubernetes Deployment Script
# This script deploys all components in the correct order

set -e  # Exit on error

echo "=========================================="
echo "Shopping App Kubernetes Deployment"
echo "=========================================="
echo ""

# Step 1: Deploy MySQL
echo "Step 1: Deploying MySQL..."
kubectl apply -f k8s/mysql-deployment.yaml
echo "✓ MySQL deployment created"
echo ""

# Step 2: Wait for MySQL to be ready
echo "Step 2: Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=180s
echo "✓ MySQL is ready"
echo ""

# Step 3: Initialize Database Tables
echo "Step 3: Initializing database tables..."
kubectl apply -f k8s/mysql-init-job.yaml
echo "Waiting for initialization job to complete..."
kubectl wait --for=condition=complete job/mysql-init --timeout=90s
echo "✓ Database tables created"
echo ""

# Step 4: Deploy Backend
echo "Step 4: Deploying Backend (Node.js)..."
kubectl apply -f k8s/backend-deployment.yaml
echo "✓ Backend deployment created"
echo ""

# Step 5: Deploy Frontend
echo "Step 5: Deploying Frontend (React)..."
kubectl apply -f k8s/frontend-deployment.yaml
echo "✓ Frontend deployment created"
echo ""

# Step 6: Wait for all deployments
echo "Step 6: Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s
echo "✓ All pods are ready"
echo ""

# Display status
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Pods:"
kubectl get pods
echo ""
echo "Services:"
kubectl get services
echo ""
echo "Persistent Volume Claims:"
kubectl get pvc
echo ""
echo "Jobs:"
kubectl get jobs
echo ""

# Get frontend URL
echo "=========================================="
echo "Application Access"
echo "=========================================="
echo "Waiting for LoadBalancer to assign external IP..."
echo "Run this command to get the frontend URL:"
echo "  kubectl get service frontend"
echo ""
echo "Or watch until EXTERNAL-IP is assigned:"
echo "  kubectl get service frontend -w"
echo ""
