from fastapi import FastAPI
from pydantic import BaseModel
from celery.result import AsyncResult
from app.tasks import example_task
from app.celery_app import celery_app

app = FastAPI(title="Celery Task Queue API")

class TaskRequest(BaseModel):
    param: str

@app.get("/")
async def root():
    return {"message": "Celery Task Queue API", "endpoints": ["/trigger-task", "/task-status/{task_id}"]}

@app.post("/trigger-task")
async def trigger_task(request: TaskRequest):
    task = example_task.delay(request.param)
    return {"task_id": task.id, "status": "queued"}

@app.get("/task-status/{task_id}")
async def task_status(task_id: str):
    res = AsyncResult(task_id, app=celery_app)
    return {"task_id": task_id, "status": res.state, "result": res.result}
