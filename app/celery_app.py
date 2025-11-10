from celery import Celery
from celery.schedules import crontab
import os

# Get RabbitMQ URL from environment variable or use default for local development
RABBITMQ_URL = os.getenv('RABBITMQ_URL', 'amqp://guest:guest@localhost:5672//')

celery_app = Celery(
    "worker",
    broker=RABBITMQ_URL,
    # backend='rpc://',  # RabbitMQ for results
    # No backend - results won't be stored (cleaner, fewer queues)
    include=['app.tasks', 'app.scheduled_tasks'],
)

celery_app.conf.update(
    timezone='Asia/Kolkata',
    enable_utc=True,
)

# Define Periodic Task schedule
celery_app.conf.beat_schedule = {
    'run-every-30-seconds': {
        'task': 'app.scheduled_tasks.my_scheduled_task',  # Task name to run
        'schedule': 60.0,                                 # Every 30 seconds
    },
}
