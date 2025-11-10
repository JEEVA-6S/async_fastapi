from app.celery_app import celery_app
from datetime import datetime
import time

@celery_app.task
def my_scheduled_task():
    print("Scheduled task is running...")
    
    # Example task logic: Log current time and do some processing
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Task executed at: {current_time}")
    
    # Simulate some work (e.g., database cleanup, sending reports, etc.)
    time.sleep(20)
    
    result = f"Scheduled task completed at {current_time}"
    print(result)
    return result
