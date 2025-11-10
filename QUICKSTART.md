# Quick Start: Deploy to Azure Container Apps

## 🎯 Prerequisites

- Azure CLI installed
- Azure subscription
- Docker installed (for local testing)

## 🚀 Deploy in 3 Steps

### Step 1: Login to Azure

```bash
az login
```

### Step 2: Run Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

### Step 3: Access Your Application

After deployment completes, you'll see:
- 🌐 FastAPI App URL
- 📊 Flower Dashboard URL  
- 🐰 RabbitMQ Management UI URL

## 📝 What Gets Deployed?

1. **Azure Container Registry** - Stores your Docker images
2. **RabbitMQ** - Message broker (Azure Container Instance)
3. **FastAPI App** - Your web API (auto-scaling)
4. **Celery Worker** - Background task processor
5. **Celery Beat** - Task scheduler
6. **Flower** - Celery monitoring dashboard

## 🧪 Test Your Deployment

```bash
# Set your FastAPI URL
FASTAPI_URL="<your-fastapi-url-from-deployment>"

# Test health endpoint
curl https://$FASTAPI_URL/

# Trigger a background task
curl -X POST https://$FASTAPI_URL/trigger-task \
  -H "Content-Type: application/json" \
  -d '{"param": "Hello Azure!", "delay": 5}'

# Get task ID from response, then check status
curl https://$FASTAPI_URL/task-status/<task-id>
```

## 📊 Monitor Your Application

1. **Flower Dashboard**: Monitor Celery tasks in real-time
2. **RabbitMQ Management**: View message queues and statistics
3. **Azure Portal**: View logs, metrics, and container status

## 🔄 Update Your Application

After making code changes:

```bash
./deploy.sh
```

The script will rebuild and redeploy all containers.

## 🗑️ Clean Up

To delete all Azure resources:

```bash
az group delete --name async-fastapi-rg --yes
```

## 📚 Next Steps

- See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed documentation
- Configure custom domains
- Set up CI/CD pipelines
- Add authentication
- Configure monitoring and alerts

## 💰 Estimated Cost

~$79-135/month for the complete setup running 24/7.

See [DEPLOYMENT.md](DEPLOYMENT.md) for cost optimization tips.
