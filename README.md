# Status Page

This project is a status page application for monitoring the health and performance of various services. It is built using Django and deployed on AWS using EKS (Elastic Kubernetes Service). The application provides real-time monitoring, logging, and alerting capabilities.

## Architecture
The application is deployed on AWS with the following components:

Elastic Load Balancer (ELB): Distributes incoming traffic to the EKS cluster.
EKS Cluster: Manages the Kubernetes environment.
Ingress: Routes traffic to the appropriate services within the cluster.
Nginx Pod: Serves as a reverse proxy for the Django application.
Gunicorn: WSGI HTTP server for running the Django application.
Django App: The core application handling requests and serving responses.
Redis: In-memory data store for caching and session management.
PostgreSQL (RDS): Relational database for persistent data storage.

Additionally, the following tools are used for monitoring and logging:
Prometheus + AlertManager: Collects metrics and sends alerts.
Grafana: Visualizes metrics and logs.
Fluentbit: Collects and forwards logs to Grafana Loki.
Grafana Loki: Stores and queries logs.

### Architecture Diagram
להוסיף תמונה

## Setup Instructions
To set up the environment, follow these steps:

1. **AWS Configuration:**
  - Run the following command to configure your AWS credentials:
```bash
    aws configure
```

2. **Domain Registration:**
  - Register the domain sm-status-page.com. This will automatically create a hosted zone in Route 53.

3. **Certificate Creation:**
  - Create a certificate in AWS Certificate Manager for the domain sm-status-page.com.
  - Attach the CNAME record to the hosted zone created by Route 53.

4. **Terraform Initialization and Application:**
   - Navigate to each directory and run terraform init followed by terraform apply to provision the infrastructure:
```bash
      cd infrastructure/vpc && terraform init && terraform apply
      cd infrastructure/security_groups && terraform init && terraform apply
      cd infrastructure/efs && terraform init && terraform apply
      cd infrastructure/eks && terraform init && terraform apply
      cd infrastructure/access_entries && terraform init && terraform apply
      cd infrastructure/rds && terraform init && terraform apply
      cd infrastructure/bastion && terraform init && terraform apply
      cd infrastructure/alb && terraform init && terraform apply
```

5. **Verification:**
   - Connect to the bastion host.
   - Run the following command to verify that all components are running in the production namespace:
```bash
    kubectl get all -n production
```


## Usage
Once the environment is set up, you can access the status page via the domain sm-status-page.com. The application provides a dashboard to monitor the health of various services.

For administrative tasks, connect to the bastion host and use kubectl to manage Kubernetes resources.

## Monitoring and Logging
The project includes comprehensive monitoring and logging solutions:

- **Monitoring:**
  - Prometheus: Collects metrics from the application and infrastructure.
  - AlertManager: Sends alerts based on predefined rules.
  - Grafana: Provides dashboards to visualize metrics.
- **Logging:**
  - Fluentbit: Collects logs from the application and system components.
  - Grafana Loki: Stores and indexes logs.
  - Grafana: Allows querying and visualizing logs.
 
## CI/CD Pipeline
The project uses GitHub Actions for continuous integration and deployment. The pipeline is triggered on changes to the repository and follows these steps:

1. **Developer:** Makes changes and pushes them to the Git repository.
2. **Git Repository:** Stores the code and configuration.
3. **GitHub Actions:** Runs automated tests and deploys to the testing environment using Terraform.

## Making Changes
To make changes to the application or infrastructure:

1. Switch to the development branch in the Git repository:
```bash
    git checkout development
```

2. Make the necessary changes to the application code or Helm charts.
3. Commit and push the changes:
```bash
    git add .
    git commit -m "Describe your changes"
    git push origin development
```
4. GitHub Actions will automatically run tests and deploy to the testing environment.

## Teardown Instructions
To destroy the environment, run terraform destroy in the following order to ensure dependencies are removed correctly:

```bash
cd infrastructure/alb && terraform destroy
cd infrastructure/bastion && terraform destroy
cd infrastructure/rds && terraform destroy
cd infrastructure/access_entries && terraform destroy
cd infrastructure/eks && terraform destroy
cd infrastructure/efs && terraform destroy
cd infrastructure/security_groups && terraform destroy
cd infrastructure/vpc && terraform destroy
```


    
