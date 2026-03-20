# deploy.ps1
# Complete deployment script for DevOps Assignment 2

Write-Host "Starting DevOps Assignment 2 Kubernetes Deployment..." -ForegroundColor Green

# Find minikube
$minikube_cmd = "minikube"
if (-Not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\Kubernetes\Minikube\minikube.exe") {
        $minikube_cmd = "C:\Program Files\Kubernetes\Minikube\minikube.exe"
    } else {
        Write-Error "Could not find minikube. Please restart your terminal or ensure minikube is installed."
        exit
    }
}

# Step 1: Point Docker client to Minikube's Docker daemon
Write-Host "1. Configuring Docker to use Minikube's environment..." -ForegroundColor Cyan
& $minikube_cmd -p minikube docker-env | Invoke-Expression

# Step 2: Build the deeply nested docker images
Write-Host "2. Building Backend Docker Image..." -ForegroundColor Cyan
docker build -t devops-assignment-backend:latest ./backend

Write-Host "3. Building Frontend Docker Image..." -ForegroundColor Cyan
docker build -t devops-assignment-frontend:latest ./frontend

# Step 3: Apply Kubernetes configurations in order
Write-Host "4. Applying Kubernetes Persistent Storage (PV and PVC)..." -ForegroundColor Cyan
kubectl apply -f k8s/database-storage.yaml

Write-Host "5. Deploying Database..." -ForegroundColor Cyan
kubectl apply -f k8s/database-deployment.yaml

Write-Host "6. Deploying Backend application..." -ForegroundColor Cyan
kubectl apply -f k8s/backend-deployment.yaml

Write-Host "7. Deploying Frontend application..." -ForegroundColor Cyan
kubectl apply -f k8s/frontend-deployment.yaml

Write-Host "8. Applying Horizontal Pod Autoscalers (HPA)..." -ForegroundColor Cyan
kubectl apply -f k8s/hpa.yaml

Write-Host "Deployment manifests applied! Waiting 10 seconds for pods to initialize..." -ForegroundColor Green
Start-Sleep -Seconds 10

# Step 4: Show status
Write-Host "Current Pods Status:" -ForegroundColor Yellow
kubectl get pods

# Step 5: Automatically launch the app
Write-Host "Opening the application in your default web browser..." -ForegroundColor Green
& $minikube_cmd service frontend
