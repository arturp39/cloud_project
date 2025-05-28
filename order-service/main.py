from dotenv import load_dotenv
load_dotenv()
from fastapi import FastAPI, responses
from pydantic import BaseModel
import psycopg2
from concurrent.futures import ThreadPoolExecutor
import asyncio
import os
import logging
import time
from contextlib import asynccontextmanager

start_time = time.time()

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.start_time = time.time()
    yield

app = FastAPI(lifespan=lifespan)
logging.basicConfig(filename="app.log", level=logging.INFO)

executor = ThreadPoolExecutor(max_workers=5)

POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")
sslmode = os.getenv("POSTGRES_SSLMODE", "disable")

def get_pg_connection():
    return psycopg2.connect(
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        sslmode=sslmode
    )

class Order(BaseModel):
    customer_name: str
    customer_address: str
    item_name: str
    quantity: int

@app.post("/order")
async def create_order(order: Order):
    def db_write():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO customer_order (customer_name, customer_address) VALUES (%s, %s) RETURNING id",
                    (order.customer_name, order.customer_address)
                )
                order_id = cur.fetchone()[0]
                cur.execute(
                    "INSERT INTO order_item (order_id, item_name, quantity) VALUES (%s, %s, %s)",
                    (order_id, order.item_name, order.quantity)
                )
                conn.commit()
        return {"order_id": order_id}

    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(executor, db_write)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/metrics")
async def metrics():
    loop = asyncio.get_running_loop()

    def fetch_order_count():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM customer_order")
                return cur.fetchone()[0]

    order_count = await loop.run_in_executor(executor, fetch_order_count)
    uptime = time.time() - app.state.start_time

    return {
        "order_count": order_count,
        "uptime_seconds": round(uptime, 2),
        "status": "ok"
    }

@app.get("/",include_in_schema=False)
def redir():
    return responses.RedirectResponse (url="/docs")
