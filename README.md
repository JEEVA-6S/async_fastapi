# FastAPI + Celery + RabbitMQ Async Task Queue# FastAPI + Celery + RabbitMQ Async Task Queue



A production-ready asynchronous task queue system built with FastAPI, Celery, and RabbitMQ, deployed on Azure Container Apps with auto-scaling capabilities.A production-ready asynchronous task queue system built with FastAPI, Celery, and RabbitMQ, designed for deployment to Azure Container Apps.



## 🚀 Live Production Application## 🌟 Features



**Deployed on Azure Container Apps:**- ⚡ **FastAPI** - Modern, fast web framework for building APIs

- 🌐 **FastAPI App**: https://fastapi-app.agreeableocean-f670c09e.eastus.azurecontainerapps.io- 🔄 **Celery** - Distributed task queue for background job processing

- 📊 **Flower Dashboard**: https://flower.agreeableocean-f670c09e.eastus.azurecontainerapps.io- 🐰 **RabbitMQ** - Reliable message broker

- 🐰 **RabbitMQ Management**: http://rabbitmq-8908.eastus.azurecontainer.io:15672- 📊 **Flower** - Real-time Celery monitoring dashboard

  - Username: `admin`- ⏰ **Scheduled Tasks** - Automated periodic task execution

  - Password: `SecurePassword123!`- 🐳 **Docker** - Containerized for easy deployment

- ☁️ **Azure Ready** - Deploy to Azure Container Apps with one command

## ✨ Features- 🔄 **CI/CD** - GitHub Actions workflow included



- ⚡ **FastAPI** - Modern, fast web framework for building APIs## 🏗️ Architecture

- 🔄 **Celery** - Distributed task queue with configurable delays

- 🐰 **RabbitMQ** - Reliable message broker```

- 📊 **Flower** - Real-time Celery monitoring dashboard┌─────────────────────────────────────────────────────┐

- ⏰ **Scheduled Tasks** - Automated periodic task execution (every 60 seconds)│                   FastAPI App                        │

- 🐳 **Docker** - Production-optimized containerization│              (HTTP API Endpoints)                    │

- ☁️ **Azure Container Apps** - Serverless deployment with auto-scaling (1-5 replicas)└─────────────────┬───────────────────────────────────┘

- 🔄 **CI/CD Ready** - GitHub Actions workflow included                  │

- 📈 **Auto-scaling** - Scale based on HTTP traffic and CPU usage                  ├──── POST /trigger-task

- 🔒 **Production Security** - Non-root user, secure credentials                  ├──── GET /task-status/{task_id}

                  └──── GET /

## 🏗️ Architecture                  │

                  ▼

```┌─────────────────────────────────────────────────────┐

┌─────────────────────────────────────────────────────┐│                   RabbitMQ                           │

│                   FastAPI App                        ││               (Message Broker)                       │

│         (1-5 replicas, auto-scaling)                 │└─────────────────┬───────────────────────────────────┘

│              HTTP API Endpoints                      │                  │

└─────────────────┬───────────────────────────────────┘        ┌─────────┴─────────┐

                  │        ▼                   ▼

                  ├──── POST /trigger-task┌──────────────┐   ┌──────────────────┐

                  ├──── GET /task-status/{task_id}│Celery Worker │   │  Celery Beat     │

                  └──── GET /│(Task Executor│   │  (Scheduler)     │

                  │└──────────────┘   └──────────────────┘

                  ▼        │

┌─────────────────────────────────────────────────────┐        └────────► Flower (Monitoring)

│                   RabbitMQ                           │```

│              (Message Broker)                        │

│         Azure Container Instance                     │## 🚀 Quick Start

└─────────────────┬───────────────────────────────────┘

                  │### Local Development

                  ├──── Celery Worker (1-3 replicas)

                  ├──── Celery Beat (1 replica)```bash

                  └──── Flower Monitoring (1 replica)# Clone the repository

```git clone <your-repo-url>

cd async_fastapi

## 🚀 Quick Start - Test the Live Application

# Create virtual environment

### Trigger a Taskpython -m venv venv

```bashsource venv/bin/activate  # On Windows: venv\Scripts\activate

curl -X POST "https://fastapi-app.agreeableocean-f670c09e.eastus.azurecontainerapps.io/trigger-task" \

  -H "Content-Type: application/json" \# Install dependencies

  -d '{"param": "hello_world", "delay": 15}'pip install -r requirements.txt

```

# Start RabbitMQ (Docker)

Response:docker run -d --hostname my-rabbit --name rabbitmq \

```json  -p 5672:5672 -p 15672:15672 \

{  rabbitmq:3-management

    "task_id": "abc123-def456-789",

    "status": "Task triggered"# Start FastAPI (Terminal 1)

}uvicorn app.main:app --reload

```

# Start Celery Worker (Terminal 2)

### Check Task Statuscelery -A app.celery_app worker --beat --loglevel=info --concurrency=4

```bash

curl "https://fastapi-app.agreeableocean-f670c09e.eastus.azurecontainerapps.io/task-status/{task_id}"# Start Flower Dashboard (Terminal 3)

```celery -A app.celery_app flower --port=5555

```

Response:

```jsonAccess:

{- FastAPI: http://localhost:8000

    "task_id": "abc123-def456-789",- FastAPI Docs: http://localhost:8000/docs

    "status": "SUCCESS",- Flower: http://localhost:5555

    "result": "Processed: hello_world after 15 seconds"- RabbitMQ Management: http://localhost:15672 (guest/guest)

}

```### Deploy to Azure



### Access Interactive API Documentation```bash

- Swagger UI: https://fastapi-app.agreeableocean-f670c09e.eastus.azurecontainerapps.io/docs# One-command deployment

- ReDoc: https://fastapi-app.agreeableocean-f670c09e.eastus.azurecontainerapps.io/redoc./deploy.sh

```

### Monitor Tasks in Real-time

Visit Flower Dashboard: https://flower.agreeableocean-f670c09e.eastus.azurecontainerapps.ioSee [QUICKSTART.md](QUICKSTART.md) for detailed deployment instructions.



## 📁 Project Structure## 📁 Project Structure



``````

.async_fastapi/

├── app/├── app/

│   ├── __init__.py│   ├── __init__.py

│   ├── main.py              # FastAPI application│   ├── main.py              # FastAPI application

│   ├── celery_app.py        # Celery configuration│   ├── celery_app.py        # Celery configuration

│   ├── tasks.py             # Celery tasks (configurable delays)│   ├── tasks.py             # Background tasks

│   └── scheduled_tasks.py   # Scheduled tasks (runs every 60s)│   └── scheduled_tasks.py   # Periodic tasks

├── infrastructure/├── infrastructure/

│   └── main.bicep           # Azure infrastructure as code│   └── main.bicep           # Azure infrastructure

├── .github/├── .github/

│   └── workflows/│   └── workflows/

│       └── azure-deploy.yml # CI/CD pipeline│       └── azure-deploy.yml # CI/CD pipeline

├── Dockerfile               # Production-optimized container├── Dockerfile               # Container image definition

├── docker-compose.azure.yml # Local development setup├── docker-compose.yml       # Local development

├── deploy.sh                # One-command Azure deployment├── docker-compose.azure.yml # Production compose

├── requirements.txt├── requirements.txt         # Python dependencies

├── DEPLOYMENT.md            # Detailed deployment guide├── deploy.sh               # Azure deployment script

├── QUICKSTART.md            # 5-minute quick start├── DEPLOYMENT.md           # Detailed deployment guide

├── CICD_SETUP.md            # GitHub Actions setup├── QUICKSTART.md           # Fast deployment guide

└── README.md├── CICD_SETUP.md          # CI/CD setup instructions

```└── README.md              # This file

```

## 💻 Local Development

## 🎯 API Endpoints

### Option 1: Docker Compose (Recommended)

### Trigger a Background Task

1. Start RabbitMQ:```bash

```bashPOST /trigger-task

docker run -d --name rabbitmq \Content-Type: application/json

  -p 5672:5672 -p 15672:15672 \

  -e RABBITMQ_DEFAULT_USER=admin \{

  -e RABBITMQ_DEFAULT_PASS=SecurePassword123! \  "param": "your data",

  rabbitmq:3-management  "delay": 10

```}

```

2. Start the application stack:

```bashResponse:

docker-compose -f docker-compose.azure.yml up -d```json

```{

  "task_id": "abc-123-def",

3. Access local services:  "status": "queued",

   - FastAPI: http://localhost:8000  "delay": 10

   - Flower: http://localhost:5555}

   - RabbitMQ: http://localhost:15672 (admin/SecurePassword123!)```



### Option 2: Manual Setup### Check Task Status

```bash

1. Install dependencies:GET /task-status/{task_id}

```bash```

pip install -r requirements.txt

```Response:

```json

2. Set environment variable:{

```bash  "task_id": "abc-123-def",

export RABBITMQ_URL="amqp://admin:SecurePassword123!@localhost:5672//"  "status": "SUCCESS",

```  "result": "Processed data: your data"

}

3. Start services (each in separate terminal):```

```bash

# FastAPI server## ⚙️ Configuration

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

### Environment Variables

# Celery worker (4 concurrent tasks)

celery -A app.celery_app worker --loglevel=info --concurrency=4| Variable | Description | Default |

|----------|-------------|---------|

# Celery Beat (scheduled tasks)| `RABBITMQ_URL` | RabbitMQ connection string | `amqp://guest:guest@localhost:5672//` |

celery -A app.celery_app beat --loglevel=info

### Scheduled Tasks

# Flower monitoring

celery -A app.celery_app flower --port=5555Edit `app/celery_app.py` to configure scheduled tasks:

```

```python

## 🌩️ Azure Deploymentcelery_app.conf.beat_schedule = {

    'run-every-60-seconds': {

### Prerequisites        'task': 'app.scheduled_tasks.my_scheduled_task',

- Azure CLI installed and authenticated (`az login`)        'schedule': 60.0,  # Run every 60 seconds

- Azure subscription with Owner role    },

- Docker installed (for local builds)}

```

### One-Command Deployment

```bash## 🐳 Docker

chmod +x deploy.sh

./deploy.sh### Build Image

``````bash

docker build -t async-fastapi .

**What it does:**```

1. ✅ Creates Azure Resource Group (`async-fastapi-rg`)

2. ✅ Creates Azure Container Registry (`asyncfastapiacr`)### Run with Docker Compose

3. ✅ Builds and pushes Docker image```bash

4. ✅ Deploys RabbitMQ Container Instancedocker-compose -f docker-compose.azure.yml up

5. ✅ Deploys Container Apps Environment with Log Analytics```

6. ✅ Deploys all services (FastAPI, Celery Worker, Beat, Flower)

## ☁️ Azure Deployment

**Deployment time**: ~10-15 minutes

**Estimated cost**: ~$79-135/month### Prerequisites

- Azure CLI installed

### Infrastructure Details- Azure subscription

- Docker (for local testing)

**Azure Resources:**

- **Resource Group**: `async-fastapi-rg` (East US)### Deploy

- **Container Registry**: `asyncfastapiacr.azurecr.io````bash

- **Container Apps Environment**: Managed environment with Log Analytics# Automated deployment

- **Container Apps**:./deploy.sh

  - `fastapi-app`: 1-5 replicas (0.5 CPU, 1GB RAM per replica)

  - `celery-worker`: 1-3 replicas (0.5 CPU, 1GB RAM per replica)# Or follow manual steps in DEPLOYMENT.md

  - `celery-beat`: 1 replica (0.25 CPU, 0.5GB RAM)```

  - `flower`: 1 replica (0.25 CPU, 0.5GB RAM)

- **RabbitMQ Container Instance**: 1 CPU, 1.5GB RAM### What Gets Deployed

- Azure Container Registry

### Manual Deployment- RabbitMQ (Azure Container Instance)

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed step-by-step instructions.- FastAPI App (Container App with auto-scaling)

- Celery Worker (Container App)

## 📊 Monitoring & Logs- Celery Beat (Container App)

- Flower Dashboard (Container App)

### View Live Logs

```bash### Cost Estimate

# FastAPI application logs~$79-135/month for complete setup

az containerapp logs show --name fastapi-app \

  --resource-group async-fastapi-rg --followSee [DEPLOYMENT.md](DEPLOYMENT.md) for detailed cost breakdown.



# Celery worker logs## 🔄 CI/CD

az containerapp logs show --name celery-worker \

  --resource-group async-fastapi-rg --follow### Setup GitHub Actions



# Celery Beat logs1. Create Azure Service Principal

az containerapp logs show --name celery-beat \2. Add `AZURE_CREDENTIALS` secret to GitHub

  --resource-group async-fastapi-rg --follow3. Push to `main` branch

```

See [CICD_SETUP.md](CICD_SETUP.md) for detailed instructions.

### Flower Dashboard

Monitor all Celery tasks, workers, and queues in real-time:### Automatic Deployment

https://flower.agreeableocean-f670c09e.eastus.azurecontainerapps.ioEvery push to `main` triggers:

- Build Docker image

Features:- Push to Azure Container Registry

- Task history and execution times- Update all Container Apps

- Worker status and concurrency- Zero-downtime deployment

- Real-time task monitoring

- Failed task analysis## 📊 Monitoring

- Task rate graphs

### Flower Dashboard

## 📡 API ReferenceMonitor Celery tasks in real-time:

- Active tasks

### Endpoints- Task history

- Worker status

#### `POST /trigger-task`- Task statistics

Trigger an asynchronous task with optional delay.

### RabbitMQ Management

**Request:**View message broker statistics:

```json- Queue status

{- Message rates

    "param": "test_data",- Connection details

    "delay": 15  // Optional, default: 10 seconds

}### Azure Portal

```- Application logs

- Metrics and monitoring

**Response:**- Container status

```json- Resource usage

{

    "task_id": "550e8400-e29b-41d4-a716-446655440000",## 🧪 Testing

    "status": "Task triggered"

}```bash

```# Run tests

pytest

#### `GET /task-status/{task_id}`

Check the status and result of a task.# Test API endpoint

curl -X POST http://localhost:8000/trigger-task \

**Response (Pending):**  -H "Content-Type: application/json" \

```json  -d '{"param": "test", "delay": 5}'

{```

    "task_id": "550e8400-e29b-41d4-a716-446655440000",

    "status": "PENDING",## 🛠️ Development

    "result": null

}### Add a New Task

```

1. Define task in `app/tasks.py`:

**Response (Success):**```python

```json@celery_app.task

{def my_new_task(param):

    "task_id": "550e8400-e29b-41d4-a716-446655440000",    # Your task logic

    "status": "SUCCESS",    return result

    "result": "Processed: test_data after 15 seconds"```

}

```2. Create API endpoint in `app/main.py`:

```python

**Response (Failure):**@app.post("/my-endpoint")

```jsonasync def trigger_my_task(request: TaskRequest):

{    task = my_new_task.delay(request.param)

    "task_id": "550e8400-e29b-41d4-a716-446655440000",    return {"task_id": task.id}

    "status": "FAILURE",```

    "result": "Error message"

}### Add a Scheduled Task

```

1. Define task in `app/scheduled_tasks.py`

#### `GET /`2. Add schedule in `app/celery_app.py`:

Root endpoint - returns welcome message.```python

'my-scheduled-task': {

## ⚙️ Configuration    'task': 'app.scheduled_tasks.my_task',

    'schedule': crontab(hour=0, minute=0),  # Daily at midnight

### Environment Variables}

```

**Production (Azure):**

```bash## 📚 Documentation

RABBITMQ_URL=amqp://admin:SecurePassword123!@rabbitmq-8908.eastus.azurecontainer.io:5672//

```- [QUICKSTART.md](QUICKSTART.md) - Fast deployment guide

- [DEPLOYMENT.md](DEPLOYMENT.md) - Detailed Azure deployment

**Local Development:**- [CICD_SETUP.md](CICD_SETUP.md) - CI/CD pipeline setup

```bash- [AZURE_DEPLOYMENT_SUMMARY.md](AZURE_DEPLOYMENT_SUMMARY.md) - Deployment overview

RABBITMQ_URL=amqp://admin:SecurePassword123!@localhost:5672//  # Default

```## 🔐 Security



### Celery Configuration- HTTPS-only endpoints in production

- **Concurrency**: 4 workers per container- Non-root container user

- **Task time limit**: No limit (configurable)- Secrets managed via Azure

- **Result backend**: RabbitMQ (task results stored for status checks)- Private container registry

- **Scheduled tasks**: Every 60 seconds (`my_scheduled_task`)- Environment-based configuration



## 📈 Scaling## 🤝 Contributing



### Auto-scaling (Configured)1. Fork the repository

- **FastAPI**: Scales 1-5 replicas based on HTTP traffic2. Create feature branch (`git checkout -b feature/amazing-feature`)

- **Celery Worker**: Scales 1-3 replicas based on CPU usage (>70%)3. Commit changes (`git commit -m 'Add amazing feature'`)

- **Celery Beat**: Fixed 1 replica (scheduler)4. Push to branch (`git push origin feature/amazing-feature`)

- **Flower**: Fixed 1 replica (monitoring)5. Open Pull Request



### Manual Scaling## 📄 License

```bash

# Scale FastAPI appThis project is licensed under the MIT License.

az containerapp update --name fastapi-app \

  --resource-group async-fastapi-rg \## 🆘 Support

  --min-replicas 2 --max-replicas 10

For issues or questions:

# Scale Celery workers- Check [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section

az containerapp update --name celery-worker \- Open an issue on GitHub

  --resource-group async-fastapi-rg \- Review Azure Container Apps [documentation](https://learn.microsoft.com/en-us/azure/container-apps/)

  --min-replicas 2 --max-replicas 5

```## 🎉 Acknowledgments



## 🔄 CI/CD Pipeline- FastAPI - https://fastapi.tiangolo.com/

- Celery - https://docs.celeryproject.org/

GitHub Actions workflow is configured for automatic deployment on push to `main` branch.- RabbitMQ - https://www.rabbitmq.com/

- Flower - https://flower.readthedocs.io/

**Setup Instructions**: See [CICD_SETUP.md](CICD_SETUP.md)

---

**Workflow includes:**

- ✅ Code checkoutMade with ❤️ for async task processing

- ✅ Azure login with Service Principal
- ✅ Docker image build and push to ACR
- ✅ Container Apps deployment
- ✅ Environment variable configuration

## 🔧 Troubleshooting

### Common Issues

**1. Tasks not executing**
- Check RabbitMQ connection in Flower dashboard
- Verify worker replicas are running: `az containerapp show --name celery-worker --resource-group async-fastapi-rg`

**2. 502 Bad Gateway**
- Container app may be restarting (wait 30-60 seconds)
- Check logs: `az containerapp logs show --name fastapi-app --resource-group async-fastapi-rg`

**3. High latency**
- Scale up worker replicas
- Check RabbitMQ queue size in management UI

**4. Deployment fails**
- Verify Azure CLI authentication: `az account show`
- Check resource quotas: Container Apps limits in your region
- Review deployment logs in Azure Portal

### Check Service Health
```bash
# Check FastAPI app status
az containerapp show --name fastapi-app \
  --resource-group async-fastapi-rg \
  --query "properties.runningStatus"

# Check all container apps
az containerapp list --resource-group async-fastapi-rg \
  --output table
```

## 🗑️ Clean Up

To delete all Azure resources and stop charges:
```bash
az group delete --name async-fastapi-rg --yes --no-wait
```

This removes:
- All Container Apps
- Container Registry
- RabbitMQ Container Instance
- Log Analytics Workspace
- All associated resources

## 📚 Documentation

- 📖 [**DEPLOYMENT.md**](DEPLOYMENT.md) - Complete deployment guide with troubleshooting
- 🚀 [**QUICKSTART.md**](QUICKSTART.md) - Get started in 5 minutes
- 🔄 [**CICD_SETUP.md**](CICD_SETUP.md) - Configure GitHub Actions CI/CD
- 📊 [**AZURE_DEPLOYMENT_SUMMARY.md**](AZURE_DEPLOYMENT_SUMMARY.md) - Architecture and infrastructure overview

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Web Framework | FastAPI | 0.104.1 |
| Task Queue | Celery | 5.3.4 |
| Message Broker | RabbitMQ | 3-management |
| Monitoring | Flower | 2.0.1 |
| Runtime | Python | 3.13 |
| Cloud Platform | Azure Container Apps | - |
| Infrastructure | Azure Bicep | - |
| CI/CD | GitHub Actions | - |
| Containerization | Docker | - |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For questions or issues:
1. Check the [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section
2. Review application logs in Azure Portal or via Azure CLI
3. Monitor task execution in Flower dashboard
4. Check RabbitMQ Management UI for queue status
5. Open an issue on GitHub with:
   - Error messages
   - Steps to reproduce
   - Environment details (local/Azure)

## 🎯 Production Checklist

- [x] Production-optimized Dockerfile with non-root user
- [x] Secure RabbitMQ credentials
- [x] Auto-scaling configuration
- [x] Health checks and monitoring
- [x] Log aggregation with Azure Log Analytics
- [x] CI/CD pipeline ready
- [x] Resource limits and quotas configured
- [x] Container Registry for image management
- [x] Infrastructure as Code (Bicep)
- [x] Documentation complete

## 🌟 Production Features

- **High Availability**: Auto-scaling ensures service availability
- **Monitoring**: Real-time task monitoring with Flower
- **Logging**: Centralized logs in Azure Log Analytics
- **Security**: Non-root container user, secure credentials
- **Scalability**: Scale from 1-5 API replicas, 1-3 worker replicas
- **Cost Optimization**: Scale down to 1 replica during low traffic
- **DevOps Ready**: One-command deployment, CI/CD pipeline included

---

**Deployed & Maintained by**: Your Team  
**Last Updated**: November 10, 2025  
**Status**: 🟢 Production Ready
