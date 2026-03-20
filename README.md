# DevOps Assignment 2: Containerization and Deployment

## Project Overview
This project is a 3-tier web application consisting of a frontend, backend, and database. It demonstrates containerization using Docker, multi-container orchestration using Docker Compose, and deployment with Kubernetes.
The application allows users to add items (name, description) to a database and view them in a list.

## Tools and Technologies Used
- **Frontend**: Nginx serving static HTML, CSS, and vanilla JavaScript.
- **Backend**: Node.js with Express framework.
- **Database**: MongoDB (v6.0).
- **Containerization**: Docker & Dockerfile.
- **Orchestration**: Docker Compose.
- **Cluster Deployment**: Kubernetes (Deployments, Services, PV, PVC, HPA).

## Application Architecture
1. **Frontend Service**: Nginx web server running on port 80 (Docker) / 30080 (K8s NodePort). A reverse proxy is configured in Nginx to forward API requests to the backend.
2. **Backend Service**: Node.js Express server running on port 3000. It connects to the MongoDB service.
3. **Database Service**: MongoDB running on default port 27017, storing application data persistently.

## Docker Build and Run Instructions
To build and run the individual containers (Task 1):

1. **Build Backend Image**:
   ```bash
   cd backend
   docker build -t devops-assignment-backend .
   ```
2. **Build Frontend Image**:
   ```bash
   cd frontend
   docker build -t devops-assignment-frontend .
   ```
3. **Run Backend** (requires local Mongo or updated MONGO_URI):
   ```bash
   docker run -p 3000:3000 --name backend-app devops-assignment-backend
   ```
4. **Run Frontend**:
   ```bash
   docker run -p 8080:80 --name frontend-app devops-assignment-frontend
   ```

## Docker Compose Setup
To run all services together using Docker Compose (Task 2):
```bash
docker-compose up --build
```
This will start the frontend, backend, and database, mapping them to local networking and setting up MongoDB volume storage. Access the application at `http://localhost:8080`.

## Kubernetes Deployment Steps
To deploy the application to a Kubernetes cluster (Tasks 3, 4, 5):

1. **Apply Persistent Storage (PV & PVC)**:
   ```bash
   kubectl apply -f k8s/database-storage.yaml
   ```
2. **Deploy the Database**:
   ```bash
   kubectl apply -f k8s/database-deployment.yaml
   ```
3. **Deploy the Backend**:
   ```bash
   kubectl apply -f k8s/backend-deployment.yaml
   ```
4. **Deploy the Frontend**:
   ```bash
   kubectl apply -f k8s/frontend-deployment.yaml
   ```

## Scaling Configuration
To apply the Horizontal Pod Autoscalers (HPA) for load management:
```bash
kubectl apply -f k8s/hpa.yaml
```
- **Frontend HPA**: Min pods = 2, Max pods = 5, Target CPU = 70%.
- **Backend HPA**: Min pods = 2, Max pods = 5, Target CPU = 70%.
Verify scaling by running: `kubectl get hpa`

*Note: You may be required to take screenshots of the running containers, pods, services, and HPA for the submission as listed in the assignment requirements.*
