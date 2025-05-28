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

# ENV VARS
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

class DeliveryAssignment(BaseModel):
    order_id: int
    courier_name: str

@app.post("/assign")
async def assign_delivery(data: DeliveryAssignment):
    def db_write():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO delivery (order_id, courier_name, status) VALUES (%s, %s, %s)",
                    (data.order_id, data.courier_name, 'assigned')
                )
                conn.commit()
        return {"assigned": True}

    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(executor, db_write)

@app.get("/metrics")
async def metrics():
    def fetch_delivery_count():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM delivery")
                return cur.fetchone()[0]

    loop = asyncio.get_running_loop()
    delivery_count = await loop.run_in_executor(executor, fetch_delivery_count)
    uptime = time.time() - app.state.start_time

    return {
        "delivery_count": delivery_count,
        "uptime_seconds": round(uptime, 2),
        "status": "ok"
    }

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/", include_in_schema=False)
def redir():
    return responses.RedirectResponse(url="/docs")
