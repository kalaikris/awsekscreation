#!/bin/bash

# Shopping App Kubernetes Cleanup Script
# This script removes all deployed resources

echo "=========================================="
echo "Shopping App Kubernetes Cleanup"
echo "=========================================="
echo ""

read -p "Are you sure you want to delete all resources? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo "Deleting resources in reverse order..."
echo ""

# Delete Frontend
echo "Deleting Frontend..."
kubectl delete -f k8s/frontend-deployment.yaml --ignore-not-found=true

# Delete Backend
echo "Deleting Backend..."
kubectl delete -f k8s/backend-deployment.yaml --ignore-not-found=true

# Delete Init Job
echo "Deleting Init Job..."
kubectl delete -f k8s/mysql-init-job.yaml --ignore-not-found=true

# Delete MySQL
echo "Deleting MySQL..."
kubectl delete -f k8s/mysql-deployment.yaml --ignore-not-found=true

echo ""
echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
echo ""
echo "Note: PersistentVolume may still exist."
echo "To delete it manually:"
echo "  kubectl delete pvc mysql-pvc"
echo ""
