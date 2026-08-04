# Kubernetes Deployment Files

This folder contains all Kubernetes deployment manifests for the Shopping App.

## Files

- `mysql-deployment.yaml` - MySQL database deployment, PVC, and service
- `backend-deployment.yaml` - Node.js backend deployment and service
- `frontend-deployment.yaml` - React frontend deployment and LoadBalancer service
- `mysql-init-job.yaml` - Database initialization job (creates tables) - **Run after MySQL is ready**
- `deploy.sh` - Automated deployment script (deploys in correct order)
- `cleanup.sh` - Cleanup script to remove all resources
- `README.md` - This file

## Quick Start (Automated)

### Deploy Everything:
```bash
./k8s/deploy.sh
```

### Cleanup Everything:
```bash
./k8s/cleanup.sh
```

## Deployment Order

### ⚠️ IMPORTANT: Deploy in this order

1. **Deploy MySQL first:**
   ```bash
   kubectl apply -f k8s/mysql-deployment.yaml
   ```

2. **Wait for MySQL to be ready (IMPORTANT):**
   ```bash
   kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s
   ```
   Or check manually:
   ```bash
   kubectl get pods -l app=mysql
   # Wait until STATUS is "Running" and READY is "1/1"
   ```

3. **Initialize Database Tables (after MySQL is ready):**
   ```bash
   kubectl apply -f k8s/mysql-init-job.yaml
   ```
   Wait for job to complete:
   ```bash
   kubectl wait --for=condition=complete job/mysql-init --timeout=60s
   ```

4. **Deploy Backend:**
   ```bash
   kubectl apply -f k8s/backend-deployment.yaml
   ```

5. **Deploy Frontend:**
   ```bash
   kubectl apply -f k8s/frontend-deployment.yaml
   ```

## Deploy All at Once (Alternative)

```bash
# Deploy MySQL and wait
kubectl apply -f k8s/mysql-deployment.yaml
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

# Initialize database and wait
kubectl apply -f k8s/mysql-init-job.yaml
kubectl wait --for=condition=complete job/mysql-init --timeout=60s

# Deploy backend and frontend
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# Check status
kubectl get pods
kubectl get services
kubectl get pvc
kubectl get jobs
```

## Access the Application

Get the external IP of the frontend:
```bash
kubectl get service frontend
```

Access the app using the EXTERNAL-IP shown.

## Environment Variables

### MySQL
- `MYSQL_ROOT_PASSWORD`: password
- `MYSQL_DATABASE`: shop

### Backend (Node.js)
- `DB_HOST`: mysql
- `DB_USER`: root
- `DB_PASSWORD`: password
- `DB_NAME`: shop
- `PORT`: 5000

### Frontend (React)
- `REACT_APP_API_URL`: http://backend:5000

## Monitoring

```bash
# View logs
kubectl logs -l app=backend
kubectl logs -l app=frontend
kubectl logs -l app=mysql

# Check pod status
kubectl get pods -w

# Describe resources
kubectl describe deployment backend
kubectl describe service frontend
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/

# Or delete individually
kubectl delete -f mysql-init-job.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f backend-deployment.yaml
kubectl delete -f mysql-deployment.yaml
```

## Notes

- **mysql-init-job.yaml must run AFTER MySQL deployment is ready** - It creates the database tables and needs MySQL to be running
- Frontend uses LoadBalancer type service for external access
- Backend and MySQL use ClusterIP (internal only)
- MySQL data is persisted using PersistentVolumeClaim (10Gi)
- Backend has 2 replicas for high availability
- Frontend has 2 replicas for load balancing
- Health checks configured for backend service
- The init job has a 30-second sleep to ensure MySQL is fully ready before creating tables
