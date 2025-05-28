from dotenv import load_dotenv
load_dotenv()
from fastapi import FastAPI, responses
from pydantic import BaseModel
import redis.asyncio as redis
import os
import logging
import psycopg2
from concurrent.futures import ThreadPoolExecutor
import asyncio
from contextlib import asynccontextmanager
import time

DATABASE_URL = os.getenv("POSTGRES_URL")
REDIS_URL = os.getenv("REDIS_URL")
POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")
sslmode = os.getenv("POSTGRES_SSLMODE", "disable")

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.redis = await redis.from_url(REDIS_URL)
    yield
    await app.state.redis.close()
    
start_time = time.time()
app = FastAPI(lifespan=lifespan)
logging.basicConfig(filename="app.log", level=logging.INFO)
executor = ThreadPoolExecutor(max_workers=5)

def get_pg_connection():
    return psycopg2.connect(
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        sslmode=sslmode
    )

def fetch_menu():
    with get_pg_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT name, price FROM menu_item")
            return [{"name": row[0], "price": float(row[1])} for row in cur.fetchall()]

@app.get("/menu")
async def get_menu():
    loop = asyncio.get_running_loop()
    result = await loop.run_in_executor(executor, fetch_menu)
    return result

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/metrics")
async def metrics():
    loop = asyncio.get_running_loop()

    def fetch_count():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM menu_item")
                return cur.fetchone()[0]

    menu_item_count = await loop.run_in_executor(executor, fetch_count)
    uptime = time.time() - start_time

    try:
        pong = await app.state.redis.ping()
        redis_status = "connected" if pong else "no response"
    except Exception:
        redis_status = "disconnected"

    return {
        "menu_item_count": menu_item_count,
        "uptime_seconds": round(uptime, 2),
        "redis_status": redis_status
    }

@app.get("/",include_in_schema=False)
def redir():
    return responses.RedirectResponse (url="/docs")