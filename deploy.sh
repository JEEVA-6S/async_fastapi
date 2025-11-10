#!/bin/bash

# Azure Container Apps Deployment Script for FastAPI + Celery + RabbitMQ

set -e

# Configuration
RESOURCE_GROUP="async-fastapi-rg"
LOCATION="eastus"
ACR_NAME="asyncfastapiacr"
RABBITMQ_CONTAINER_NAME="rabbitmq-container"
IMAGE_NAME="async-fastapi"
IMAGE_TAG="latest"

echo "🚀 Starting Azure Container Apps Deployment..."

# 1. Login to Azure
echo "📝 Step 1: Login to Azure"
az login

# 2. Create Resource Group
echo "📝 Step 2: Creating Resource Group"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# 3. Create Azure Container Registry
echo "📝 Step 3: Creating Azure Container Registry"
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# 4. Get ACR credentials
echo "📝 Step 4: Getting ACR credentials"
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)
ACR_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

# 5. Build and push Docker image
echo "📝 Step 5: Building and pushing Docker image"
az acr build \
  --registry $ACR_NAME \
  --image $IMAGE_NAME:$IMAGE_TAG \
  --file Dockerfile \
  .

# 6. Deploy RabbitMQ as a Container Instance
echo "📝 Step 6: Deploying RabbitMQ Container Instance"
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $RABBITMQ_CONTAINER_NAME \
  --image rabbitmq:3-management \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --dns-name-label "rabbitmq-${RANDOM}" \
  --ports 5672 15672 \
  --environment-variables RABBITMQ_DEFAULT_USER=admin RABBITMQ_DEFAULT_PASS=SecurePassword123!

# Get RabbitMQ FQDN
RABBITMQ_FQDN=$(az container show \
  --resource-group $RESOURCE_GROUP \
  --name $RABBITMQ_CONTAINER_NAME \
  --query ipAddress.fqdn -o tsv)

RABBITMQ_URL="amqp://admin:SecurePassword123!@${RABBITMQ_FQDN}:5672//"

echo "🐰 RabbitMQ URL: $RABBITMQ_URL"
echo "🐰 RabbitMQ Management UI: http://${RABBITMQ_FQDN}:15672"

# 7. Deploy Container Apps using Bicep
echo "📝 Step 7: Deploying Container Apps"
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infrastructure/main.bicep \
  --parameters \
    containerRegistryServer=$ACR_SERVER \
    containerRegistryUsername=$ACR_USERNAME \
    containerRegistryPassword=$ACR_PASSWORD \
    rabbitmqConnectionString=$RABBITMQ_URL \
    imageTag=$IMAGE_TAG

# 8. Get application URLs
echo "📝 Step 8: Getting application URLs"
FASTAPI_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.fastApiUrl.value -o tsv)

FLOWER_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.flowerUrl.value -o tsv)

echo ""
echo "✅ Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 FastAPI App: https://$FASTAPI_URL"
echo "📊 Flower Dashboard: https://$FLOWER_URL"
echo "🐰 RabbitMQ Management: http://${RABBITMQ_FQDN}:15672"
echo "   Username: admin"
echo "   Password: SecurePassword123!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 To view logs:"
echo "   az containerapp logs show --name fastapi-app --resource-group $RESOURCE_GROUP --follow"
echo ""
echo "📝 To update the application:"
echo "   ./deploy.sh"
