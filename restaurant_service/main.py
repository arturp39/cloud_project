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
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
from strawberry.fastapi import GraphQLRouter
from strawberry import Schema
import strawberry
from typing import List, Optional
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from log_to_queue import ServiceBusLogHandler, setup_logging

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
    redis_client = await redis.from_url(REDIS_URL)
    FastAPICache.init(RedisBackend(redis_client), prefix="fastapi-cache")
    app.state.redis = redis_client
    yield
    await app.state.redis.close()
    
start_time = time.time()
app = FastAPI(lifespan=lifespan)
setup_logging()
logger = logging.getLogger(__name__)
logger.addHandler(ServiceBusLogHandler())

executor = ThreadPoolExecutor(max_workers=5)

def get_pg_connection():
    return psycopg2.connect(
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        sslmode="require"
    )

def fetch_menu():
    with get_pg_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT name, price FROM menu_item")
            return [{"name": row[0], "price": float(row[1])} for row in cur.fetchall()]

@strawberry.type
class MenuItem:
    name: str
    price: float

@strawberry.type
class Query:
    @strawberry.field
    async def menu_items(self) -> List[MenuItem]:
        loop = asyncio.get_running_loop()
        items = await loop.run_in_executor(executor, fetch_menu)
        return [MenuItem(name=item["name"], price=item["price"]) for item in items]
    
    @strawberry.field
    async def menu_item(self, name: str) -> Optional[MenuItem]:
        loop = asyncio.get_running_loop()
        items = await loop.run_in_executor(executor, fetch_menu)
        for item in items:
            if item["name"] == name:
                return MenuItem(name=item["name"], price=item["price"])
        return None

schema = Schema(query=Query)
graphql_app = GraphQLRouter(schema)

@app.get("/menu")
@cache(expire=300)
async def get_menu():
    loop = asyncio.get_running_loop()
    result = await loop.run_in_executor(executor, fetch_menu)
    return result

@app.get("/health")
async def health():
    try:
        pong = await app.state.redis.ping()
        redis_status = "ok" if pong else "error"
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
    loop = asyncio.get_running_loop()

    def fetch_stats():
        with get_pg_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM menu_item")
                menu_count = cur.fetchone()[0]
                cur.execute("SELECT AVG(price) FROM menu_item")
                avg_price = cur.fetchone()[0]
                return menu_count, float(avg_price) if avg_price else 0

    menu_item_count, avg_price = await loop.run_in_executor(executor, fetch_stats)
    uptime = time.time() - start_time

    try:
        pong = await app.state.redis.ping()
        redis_status = "connected" if pong else "no response"
        cache_info = await app.state.redis.info("stats")
        cache_hits = int(cache_info.get("keyspace_hits", 0))
        cache_misses = int(cache_info.get("keyspace_misses", 0))
    except Exception:
        redis_status = "disconnected"
        cache_hits = 0
        cache_misses = 0

    return {
        "menu_item_count": menu_item_count,
        "average_price": round(avg_price, 2),
        "uptime_seconds": round(uptime, 2),
        "redis_status": redis_status,
        "cache_stats": {
            "hits": cache_hits,
            "misses": cache_misses,
            "hit_ratio": round(cache_hits / (cache_hits + cache_misses), 2) if (cache_hits + cache_misses) > 0 else 0
        }
    }

@app.get("/", include_in_schema=False)
def redir():
    return responses.RedirectResponse(url="/docs")

app.include_router(graphql_app, prefix="/graphql")