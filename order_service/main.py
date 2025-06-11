from dotenv import load_dotenv
load_dotenv()
from fastapi import FastAPI, responses, HTTPException, BackgroundTasks, Depends
from pydantic import BaseModel
import psycopg2
from concurrent.futures import ThreadPoolExecutor
import asyncio
import os
import logging
import time
from contextlib import asynccontextmanager
import json
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
from cryptography.fernet import Fernet
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
from redis import asyncio as aioredis
from strawberry.fastapi import GraphQLRouter
from strawberry import Schema
import strawberry
from typing import List, Optional
from datetime import datetime
import backoff
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from log_to_queue import ServiceBusLogHandler, setup_logging
from fastapi.middleware.cors import CORSMiddleware
import redis

start_time = time.time()

POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")
ENCRYPTION_KEY = os.getenv("ENCRYPTION_KEY")
cipher = Fernet(ENCRYPTION_KEY.encode())
REDIS_URL = os.getenv("REDIS_URL")
SERVICE_BUS_CONNECTION_STRING = os.getenv("SERVICE_BUS")
SERVICE_BUS_QUEUE_NAME = os.getenv("SERVICE_BUS_QUEUE_NAME") 
LOG_QUEUE_NAME = os.getenv("LOG_QUEUE_NAME")
setup_logging()
logger = logging.getLogger(__name__)
redis_client = redis.Redis.from_url(REDIS_URL, decode_responses=True)
service_bus_client = None
service_bus_sender = None

@backoff.on_exception(backoff.expo, Exception, max_tries=5)
def get_pg_connection():
    try:
        logger.info("Attempting to connect to database...")
        conn = psycopg2.connect(
            dbname=POSTGRES_DB,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
            host=POSTGRES_HOST,
            port=POSTGRES_PORT,
            sslmode="require",
            connect_timeout=10
        )
        logger.info("Successfully connected to database")
        return conn
    except Exception as e:
        logger.error(f"Failed to connect to database: {e}")
        raise

@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        # Initialize Redis
        redis_client = await aioredis.from_url(
            REDIS_URL,
            encoding="utf8",
            decode_responses=True,
            socket_timeout=5,
            socket_connect_timeout=5
        )
        await redis_client.ping()
        FastAPICache.init(RedisBackend(redis_client), prefix="fastapi-cache")
        logger.info("Successfully connected to Redis")

        # Initialize Service Bus
        global service_bus_client, service_bus_sender
        logger.info("Initializing Service Bus connection...")
        if SERVICE_BUS_CONNECTION_STRING:
            service_bus_client = ServiceBusClient.from_connection_string(
                conn_str=SERVICE_BUS_CONNECTION_STRING,
                logging_enable=True
            )
            service_bus_sender = service_bus_client.get_queue_sender(queue_name=SERVICE_BUS_QUEUE_NAME)
            logger.info("Service Bus connection initialized successfully")
        else:
            logger.warning("Service Bus connection string not set")

    except Exception as e:
        logger.error(f"Initialization error: {e}")
        raise

    yield

    # Shutdown logic
    try:
        if service_bus_sender:
            await service_bus_sender.close()
        if service_bus_client:
            await service_bus_client.close()
        await redis_client.close()
        logger.info("Resources closed successfully")
    except Exception as e:
        logger.error(f"Shutdown error: {e}")

app = FastAPI(title="Order Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

executor = ThreadPoolExecutor(max_workers=5)

@backoff.on_exception(backoff.expo, Exception, max_tries=3)
async def send_to_queue(payload: dict):
    if not SERVICE_BUS_CONNECTION_STRING or not SERVICE_BUS_QUEUE_NAME:
        logger.warning("Service Bus connection string or queue name not set")
        return
        
    try:
        async with ServiceBusClient.from_connection_string(
            SERVICE_BUS_CONNECTION_STRING,
            logging_enable=True
        ) as client:
            sender = client.get_queue_sender(queue_name=SERVICE_BUS_QUEUE_NAME)
            async with sender:
                msg = ServiceBusMessage(json.dumps(payload))
                await sender.send_messages(msg)
                logger.info(f"Successfully sent message to queue: {SERVICE_BUS_QUEUE_NAME}")
    except Exception as e:
        logger.error(f"Failed to send message to Service Bus: {e}")
        raise

class OrderCreate(BaseModel):
    customer_name: str
    customer_address: str
    item_name: str
    quantity: int

@app.post("/order")
async def create_order(order: OrderCreate):
    def db_write():
        encrypted_name = cipher.encrypt(order.customer_name.encode()).decode()
        encrypted_address = cipher.encrypt(order.customer_address.encode()).decode()

        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO customer_order (customer_name, customer_address) VALUES (%s, %s) RETURNING id",
                    (encrypted_name, encrypted_address)
                )
                order_id = cur.fetchone()[0]
                cur.execute(
                    "INSERT INTO order_item (order_id, item_name, quantity) VALUES (%s, %s, %s)",
                    (order_id, order.item_name, order.quantity)
                )
                conn.commit()
        return order_id, encrypted_name, encrypted_address

    loop = asyncio.get_running_loop()
    order_id, encrypted_name, encrypted_address = await loop.run_in_executor(executor, db_write)

    message = {
        "order_id": order_id,
        "customer_name": encrypted_name,
        "customer_address": encrypted_address,
        "item_name": order.item_name,
        "quantity": order.quantity
    }
    await send_to_queue(message)

    return {"order_id": order_id}

@app.get("/health")
async def health():
    try:
        redis_client = await aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True)
        await redis_client.ping()
        redis_status = "ok"
        await redis_client.close()
    except Exception as e:
        redis_status = "error"
        logging.error(f"Redis health check failed: {e}")

    try:
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                db_status = "ok"
    except Exception as e:
        db_status = "error"
        logging.error(f"Database health check failed: {e}")

    return {
        "status": "ok" if db_status == "ok" and redis_status == "ok" else "error",
        "components": {
            "database": db_status,
            "cache": redis_status
        }
    }

@app.get("/metrics")
@cache(expire=30)
async def metrics():
    def fetch_order_count():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM customer_order")
                return cur.fetchone()[0]

    loop = asyncio.get_running_loop()
    order_count = await loop.run_in_executor(executor, fetch_order_count)
    uptime = time.time() - start_time

    try:
        redis_client = await aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True)
        await redis_client.ping()
        redis_status = "connected"
        await redis_client.close()
    except Exception:
        redis_status = "disconnected"

    return {
        "order_count": order_count,
        "uptime_seconds": round(uptime, 2),
        "redis_status": redis_status,
        "status": "ok"
    }

@app.get("/", include_in_schema=False)
def redir():
    return responses.RedirectResponse(url="/docs")

@strawberry.type
class OrderItem:
    item_name: str
    quantity: int

@strawberry.type
class Order:
    id: int
    customer_name: str
    customer_address: str
    created_at: datetime
    items: List[OrderItem]

@strawberry.type
class Query:
    @strawberry.field
    async def orders(self) -> List[Order]:
        def fetch_orders():
            with get_pg_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("""
                        SELECT o.id, o.customer_name, o.customer_address, o.created_at, 
                               i.item_name, i.quantity
                        FROM customer_order o
                        LEFT JOIN order_item i ON o.id = i.order_id
                        ORDER BY o.created_at DESC
                    """)
                    rows = cur.fetchall()
                    
                    orders = {}
                    for row in rows:
                        order_id = row[0]
                        if order_id not in orders:
                            orders[order_id] = {
                                'id': order_id,
                                'customer_name': cipher.decrypt(row[1].encode()).decode(),
                                'customer_address': cipher.decrypt(row[2].encode()).decode(),
                                'created_at': row[3],
                                'items': []
                            }
                        if row[4]:  # item_name
                            orders[order_id]['items'].append({
                                'item_name': row[4],
                                'quantity': row[5]
                            })
                    return list(orders.values())

        loop = asyncio.get_running_loop()
        orders = await loop.run_in_executor(executor, fetch_orders)
        return [Order(**order) for order in orders]
    
    @strawberry.field
    async def order(self, id: int) -> Optional[Order]:
        def fetch_order():
            with get_pg_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("""
                        SELECT o.id, o.customer_name, o.customer_address, o.created_at, 
                               i.item_name, i.quantity
                        FROM customer_order o
                        LEFT JOIN order_item i ON o.id = i.order_id
                        WHERE o.id = %s
                    """, (id,))
                    rows = cur.fetchall()
                    if not rows:
                        return None
                    
                    order = {
                        'id': rows[0][0],
                        'customer_name': cipher.decrypt(rows[0][1].encode()).decode(),
                        'customer_address': cipher.decrypt(rows[0][2].encode()).decode(),
                        'created_at': rows[0][3],
                        'items': []
                    }
                    
                    for row in rows:
                        if row[4]:  # item_name
                            order['items'].append({
                                'item_name': row[4],
                                'quantity': row[5]
                            })
                    return order

        loop = asyncio.get_running_loop()
        order = await loop.run_in_executor(executor, fetch_order)
        return Order(**order) if order else None

schema = Schema(query=Query)
graphql_app = GraphQLRouter(schema)

app.include_router(graphql_app, prefix="/graphql")