targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name')
param environmentName string = 'async-fastapi-env'

@description('RabbitMQ connection string')
@secure()
param rabbitmqConnectionString string

@description('Container Registry Server')
param containerRegistryServer string

@description('Container Registry Username')
param containerRegistryUsername string

@description('Container Registry Password')
@secure()
param containerRegistryPassword string

@description('Container image tag')
param imageTag string = 'latest'

// Container Apps Environment
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${environmentName}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// FastAPI Container App
resource fastApiApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'fastapi-app'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          server: containerRegistryServer
          username: containerRegistryUsername
          passwordSecretRef: 'registry-password'
        }
      ]
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistryPassword
        }
        {
          name: 'rabbitmq-url'
          value: rabbitmqConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'fastapi'
          image: '${containerRegistryServer}/async-fastapi:${imageTag}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'RABBITMQ_URL'
              secretRef: 'rabbitmq-url'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// Celery Worker Container App
resource celeryWorkerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'celery-worker'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      registries: [
        {
          server: containerRegistryServer
          username: containerRegistryUsername
          passwordSecretRef: 'registry-password'
        }
      ]
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistryPassword
        }
        {
          name: 'rabbitmq-url'
          value: rabbitmqConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'celery-worker'
          image: '${containerRegistryServer}/async-fastapi:${imageTag}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          command: [
            'celery'
            '-A'
            'app.celery_app'
            'worker'
            '--loglevel=info'
            '--concurrency=4'
          ]
          env: [
            {
              name: 'RABBITMQ_URL'
              secretRef: 'rabbitmq-url'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

// Celery Beat Container App
resource celeryBeatApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'celery-beat'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      registries: [
        {
          server: containerRegistryServer
          username: containerRegistryUsername
          passwordSecretRef: 'registry-password'
        }
      ]
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistryPassword
        }
        {
          name: 'rabbitmq-url'
          value: rabbitmqConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'celery-beat'
          image: '${containerRegistryServer}/async-fastapi:${imageTag}'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          command: [
            'celery'
            '-A'
            'app.celery_app'
            'beat'
            '--loglevel=info'
          ]
          env: [
            {
              name: 'RABBITMQ_URL'
              secretRef: 'rabbitmq-url'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// Flower Monitoring Container App
resource flowerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'flower'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 5555
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          server: containerRegistryServer
          username: containerRegistryUsername
          passwordSecretRef: 'registry-password'
        }
      ]
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistryPassword
        }
        {
          name: 'rabbitmq-url'
          value: rabbitmqConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'flower'
          image: '${containerRegistryServer}/async-fastapi:${imageTag}'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          command: [
            'celery'
            '-A'
            'app.celery_app'
            'flower'
            '--port=5555'
          ]
          env: [
            {
              name: 'CELERY_BROKER_URL'
              secretRef: 'rabbitmq-url'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output fastApiUrl string = fastApiApp.properties.configuration.ingress.fqdn
output flowerUrl string = flowerApp.properties.configuration.ingress.fqdn
