# Deployment Guide: FastAPI + Celery + RabbitMQ to Azure Container Apps

This guide will help you deploy your FastAPI application with Celery workers and RabbitMQ to Azure Container Apps.

## 📋 Prerequisites

1. **Azure CLI** installed ([Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
2. **Azure Subscription** with appropriate permissions
3. **Docker** installed locally (for local testing)
4. **Git** repository set up

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Azure Container Apps                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  FastAPI App │  │Celery Worker │  │ Celery Beat  │  │
│  │  (Port 8000) │  │ (Background) │  │ (Scheduler)  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                  │                  │          │
│         └──────────────────┴──────────────────┘          │
│                            │                              │
│  ┌──────────────┐         │         ┌──────────────┐    │
│  │    Flower    │◄────────┴────────►│  RabbitMQ    │    │
│  │  (Port 5555) │                    │(Container Ins│    │
│  └──────────────┘                    └──────────────┘    │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Deploy (Automated)

### Option 1: Using the Deployment Script

```bash
# Make the script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

This will:
- Create Azure Resource Group
- Create Azure Container Registry (ACR)
- Build and push your Docker image
- Deploy RabbitMQ as Azure Container Instance
- Deploy FastAPI, Celery Worker, Celery Beat, and Flower as Container Apps

## 📝 Manual Deployment Steps

### 1. Setup Azure Resources

```bash
# Login to Azure
az login

# Set variables
RESOURCE_GROUP="async-fastapi-rg"
LOCATION="eastus"
ACR_NAME="asyncfastapiacr"  # Must be globally unique

# Create Resource Group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

### 2. Create Azure Container Registry

```bash
# Create ACR
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)
ACR_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

echo "ACR Server: $ACR_SERVER"
```

### 3. Build and Push Docker Image

```bash
# Build and push image to ACR
az acr build \
  --registry $ACR_NAME \
  --image async-fastapi:latest \
  --file Dockerfile \
  .
```

### 4. Deploy RabbitMQ

**Option A: Azure Container Instances (Simple)**

```bash
az container create \
  --resource-group $RESOURCE_GROUP \
  --name rabbitmq-container \
  --image rabbitmq:3-management \
  --dns-name-label rabbitmq-${RANDOM} \
  --ports 5672 15672 \
  --cpu 1 \
  --memory 2 \
  --environment-variables \
    RABBITMQ_DEFAULT_USER=admin \
    RABBITMQ_DEFAULT_PASS=YourSecurePassword123!

# Get RabbitMQ FQDN
RABBITMQ_FQDN=$(az container show \
  --resource-group $RESOURCE_GROUP \
  --name rabbitmq-container \
  --query ipAddress.fqdn -o tsv)

RABBITMQ_URL="amqp://admin:YourSecurePassword123!@${RABBITMQ_FQDN}:5672//"
echo "RabbitMQ URL: $RABBITMQ_URL"
```

**Option B: Azure Service Bus (Managed Service - Recommended for Production)**

```bash
# Create Service Bus Namespace
az servicebus namespace create \
  --resource-group $RESOURCE_GROUP \
  --name async-fastapi-sb \
  --location $LOCATION \
  --sku Standard

# Get connection string
SERVICE_BUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name async-fastapi-sb \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString -o tsv)
```

### 5. Deploy Container Apps

```bash
# Deploy using Bicep template
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infrastructure/main.bicep \
  --parameters \
    containerRegistryServer=$ACR_SERVER \
    containerRegistryUsername=$ACR_USERNAME \
    containerRegistryPassword=$ACR_PASSWORD \
    rabbitmqConnectionString=$RABBITMQ_URL \
    imageTag=latest
```

### 6. Get Application URLs

```bash
# FastAPI App URL
az containerapp show \
  --name fastapi-app \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn -o tsv

# Flower Dashboard URL
az containerapp show \
  --name flower \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn -o tsv
```

## 🔧 Configuration

### Environment Variables

The following environment variables are configured:

| Service | Variable | Description |
|---------|----------|-------------|
| All | `RABBITMQ_URL` | RabbitMQ connection string |
| FastAPI | `PORT` | HTTP port (default: 8000) |
| Celery Worker | `CONCURRENCY` | Number of worker threads |

### Scaling Configuration

**FastAPI App:**
- Min replicas: 1
- Max replicas: 5
- Scale based on HTTP requests (10 concurrent requests per instance)

**Celery Worker:**
- Min replicas: 1
- Max replicas: 3
- Manual scaling or custom metrics

**Celery Beat:**
- Fixed: 1 replica (scheduler should be singleton)

**Flower:**
- Fixed: 1 replica

## 📊 Monitoring

### View Logs

```bash
# FastAPI logs
az containerapp logs show \
  --name fastapi-app \
  --resource-group $RESOURCE_GROUP \
  --follow

# Celery Worker logs
az containerapp logs show \
  --name celery-worker \
  --resource-group $RESOURCE_GROUP \
  --follow

# Celery Beat logs
az containerapp logs show \
  --name celery-beat \
  --resource-group $RESOURCE_GROUP \
  --follow
```

### Access Flower Dashboard

Visit the Flower URL to monitor Celery tasks in real-time.

### Access RabbitMQ Management UI

Visit `http://<rabbitmq-fqdn>:15672` and login with:
- Username: `admin`
- Password: `YourSecurePassword123!`

## 🔄 Update/Redeploy

To update your application after code changes:

```bash
# Rebuild and push image
az acr build \
  --registry $ACR_NAME \
  --image async-fastapi:$(date +%Y%m%d-%H%M%S) \
  --file Dockerfile \
  .

# Update container apps with new image
az containerapp update \
  --name fastapi-app \
  --resource-group $RESOURCE_GROUP \
  --image $ACR_SERVER/async-fastapi:latest

# Repeat for other services
az containerapp update --name celery-worker --resource-group $RESOURCE_GROUP --image $ACR_SERVER/async-fastapi:latest
az containerapp update --name celery-beat --resource-group $RESOURCE_GROUP --image $ACR_SERVER/async-fastapi:latest
az containerapp update --name flower --resource-group $RESOURCE_GROUP --image $ACR_SERVER/async-fastapi:latest
```

## 🧪 Testing

### Test FastAPI Endpoint

```bash
# Get FastAPI URL
FASTAPI_URL=$(az containerapp show \
  --name fastapi-app \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn -o tsv)

# Test health endpoint
curl https://$FASTAPI_URL/

# Trigger a task
curl -X POST https://$FASTAPI_URL/trigger-task \
  -H "Content-Type: application/json" \
  -d '{"param": "test data"}'

# Check task status
curl https://$FASTAPI_URL/task-status/<task-id>
```

## 💰 Cost Estimation

Approximate monthly costs (East US region):

| Resource | Tier/SKU | Estimated Cost |
|----------|----------|----------------|
| Container Apps Environment | N/A | $0 |
| FastAPI App (0.5 vCPU, 1Gi) | Consumption | ~$15-30/month |
| Celery Worker (0.5 vCPU, 1Gi) | Consumption | ~$15-30/month |
| Celery Beat (0.25 vCPU, 0.5Gi) | Consumption | ~$7-15/month |
| Flower (0.25 vCPU, 0.5Gi) | Consumption | ~$7-15/month |
| Azure Container Registry | Basic | ~$5/month |
| RabbitMQ (Container Instance) | 1 vCPU, 2Gi | ~$30-40/month |

**Total: ~$79-135/month**

**💡 Cost Optimization:**
- Use Azure Service Bus instead of Container Instance for RabbitMQ (~$10/month)
- Scale down non-production environments
- Use consumption-based pricing

## 🗑️ Cleanup

To delete all resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## 🔐 Security Best Practices

1. **Use Managed Identity** instead of container registry credentials where possible
2. **Store secrets in Azure Key Vault**
3. **Enable HTTPS only** (already configured)
4. **Restrict network access** using VNet integration
5. **Use strong passwords** for RabbitMQ
6. **Enable authentication** on Flower dashboard
7. **Regular updates** of base images

## 📚 Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Celery Documentation](https://docs.celeryproject.org/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)

## 🆘 Troubleshooting

### Container won't start

```bash
# Check revision details
az containerapp revision list \
  --name fastapi-app \
  --resource-group $RESOURCE_GROUP -o table

# View specific revision logs
az containerapp logs show \
  --name fastapi-app \
  --resource-group $RESOURCE_GROUP \
  --revision <revision-name>
```

### RabbitMQ connection issues

- Verify RabbitMQ container is running
- Check RABBITMQ_URL environment variable
- Ensure firewall rules allow port 5672
- Check RabbitMQ logs

### Tasks not executing

- Check Celery worker logs
- Verify RabbitMQ connection
- Check Flower dashboard for task status
- Ensure beat scheduler is running

## 📞 Support

For issues or questions, please check:
- Azure Container Apps [Troubleshooting Guide](https://learn.microsoft.com/en-us/azure/container-apps/troubleshooting)
- Project GitHub Issues
