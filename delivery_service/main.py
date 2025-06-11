from dotenv import load_dotenv
load_dotenv()
import os
from fastapi import FastAPI, responses, HTTPException, Depends
from pydantic import BaseModel
import psycopg2
from concurrent.futures import ThreadPoolExecutor
import asyncio
from contextlib import asynccontextmanager
import json
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
import sys
import logging
from cryptography.fernet import Fernet
import base64
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
from redis import asyncio as aioredis
from strawberry.fastapi import GraphQLRouter
from strawberry import Schema
import strawberry
from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from models import Base, Delivery, DeliveryStatus
from database import engine, get_db
from schemas import DeliveryCreate, DeliveryResponse
from log_to_queue import ServiceBusLogHandler, setup_logging

ENCRYPTION_KEY = os.getenv("ENCRYPTION_KEY")
fernet = Fernet(ENCRYPTION_KEY.encode())
REDIS_URL = os.getenv("REDIS_URL")
SERVICE_BUS_CONNECTION_STR = os.getenv("SERVICE_BUS")
SERVICE_BUS_QUEUE_NAME = os.getenv("SERVICE_BUS_QUEUE_NAME")
POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")

def get_pg_connection():
    return psycopg2.connect(
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT
    )

executor = ThreadPoolExecutor(max_workers=5)

def encrypt_data(data: str) -> str:
    return base64.b64encode(fernet.encrypt(data.encode())).decode()

def decrypt_data(data: str) -> str:
    return fernet.decrypt(base64.b64decode(data.encode())).decode()

setup_logging()
logger = logging.getLogger(__name__)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Delivery Service")

class DeliveryAssignment(BaseModel):
    order_id: int
    courier_name: str

@strawberry.type
class DeliveryType:
    id: int
    order_id: int
    courier_name: str
    status: str
    created_at: str
    updated_at: str

@strawberry.type
class Query:
    @strawberry.field
    def deliveries(self) -> List[DeliveryType]:
        db = next(get_db())
        deliveries = db.query(Delivery).all()
        return [
            DeliveryType(
                id=d.id,
                order_id=d.order_id,
                courier_name=d.courier_name,
                status=d.status.value,
                created_at=d.created_at.isoformat(),
                updated_at=d.updated_at.isoformat()
            )
            for d in deliveries
        ]

schema = strawberry.Schema(query=Query)
graphql_app = GraphQLRouter(schema)

app.include_router(graphql_app, prefix="/graphql")

async def consume_from_queue(app: FastAPI):
    if not SERVICE_BUS_CONNECTION_STR or not SERVICE_BUS_QUEUE_NAME:
        logger.warning("Service Bus connection string or queue name not set. Queue consumer not started.")
        return

    while True:
        try:
            async with ServiceBusClient.from_connection_string(
                conn_str=SERVICE_BUS_CONNECTION_STR,
                logging_enable=True
            ) as client:
                async with client.get_queue_receiver(queue_name=SERVICE_BUS_QUEUE_NAME) as receiver:
                    async for message in receiver:
                        try:
                            raw_bytes = b''.join([chunk for chunk in message.body])
                            raw = raw_bytes.decode("utf-8")
                            data = json.loads(raw)
                            logger.info(f"Received message: {data}")

                            with get_pg_connection() as conn:
                                with conn.cursor() as cur:
                                    logger.info(f"Inserting delivery into DB for order_id {data['order_id']}")
                                    cur.execute(
                                        "INSERT INTO deliveries (order_id, courier_name, status) VALUES (%s, %s, %s)",
                                        (data["order_id"], "auto-assigned", "PENDING")
                                    )
                                    logger.info(f"Inserted delivery into DB for order_id {data['order_id']}")
                                    conn.commit()
                            await receiver.complete_message(message)

                        except Exception as e:
                            logger.error(f"Error processing message: {e}")
                            await receiver.abandon_message(message)
        except Exception as e:
            logger.error(f"Error in queue consumer: {e}")
            await asyncio.sleep(5)

@app.on_event("startup")
async def startup_event():
    logging.info("startup: starting background consumer")
    app.state.task = asyncio.create_task(consume_from_queue(app))
    
    redis = aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True)
    FastAPICache.init(RedisBackend(redis), prefix="fastapi-cache")

@app.on_event("shutdown")
async def shutdown_event():
    logging.info("shutdown: cancelling background task")
    app.state.task.cancel()
    try:
        await app.state.task
    except asyncio.CancelledError:
        logging.info("background task cancelled")
    
    for handler in logging.getLogger().handlers:
        if isinstance(handler, ServiceBusLogHandler):
            await handler.close()

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/", include_in_schema=False)
def redir():
    return responses.RedirectResponse(url="/docs")

@app.post("/deliveries/", response_model=DeliveryResponse)
async def create_delivery(delivery: DeliveryCreate, db: Session = Depends(get_db)):
    db_delivery = Delivery(
        order_id=delivery.order_id,
        courier_name=delivery.courier_name
    )
    db.add(db_delivery)
    db.commit()
    db.refresh(db_delivery)
    return db_delivery

@app.get("/deliveries/{delivery_id}", response_model=DeliveryResponse)
async def get_delivery(delivery_id: int, db: Session = Depends(get_db)):
    try:
        delivery = db.query(Delivery).filter(Delivery.id == delivery_id).first()
        if delivery is None:
            raise HTTPException(status_code=404, detail="Delivery not found")
        return delivery
    except Exception as e:
        logger.error(f"Error fetching delivery: {e}")
        raise


@app.put("/deliveries/{delivery_id}/status")
async def update_delivery_status(delivery_id: int, status: DeliveryStatus, db: Session = Depends(get_db)):
    delivery = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if delivery is None:
        raise HTTPException(status_code=404, detail="Delivery not found")
    
    delivery.status = status
    db.commit()
    db.refresh(delivery)
    return delivery