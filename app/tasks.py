from app.celery_app import celery_app
import time

@celery_app.task
def example_task(data):
    delay = 10  # 30 seconds delay
    print(f"Starting task with {delay}s delay...")
    time.sleep(delay)
    print(f"Task completed after {delay}s")
    return f"Processed data: {data}"
