import logging
import json
import os
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
import asyncio
from datetime import datetime

SERVICE_BUS_CONNECTION_STRING = os.getenv("SERVICE_BUS")
LOG_QUEUE_NAME = os.getenv("LOG_QUEUE_NAME", "logs")

class ServiceBusLogHandler(logging.Handler):
    def __init__(self, level=logging.NOTSET):
        super().__init__(level)
        self._client = None
        self._sender = None
        self._initialized = False
        self._init_lock = asyncio.Lock()
        self._connection_lock = asyncio.Lock()
        self._pending_tasks = set()
        self._loop = None

    def _get_or_create_loop(self):
        try:
            return asyncio.get_running_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            return loop

    def emit(self, record):
        try:
            self._loop = self._get_or_create_loop()
            task = self._loop.create_task(self.emit_async(record))
            self._pending_tasks.add(task)
            task.add_done_callback(self._pending_tasks.discard)
        except Exception as e:
            print(f"Error in emit: {str(e)}")
            self.handleError(record)

    async def _ensure_initialized(self):
        if not self._initialized:
            async with self._init_lock:
                if not self._initialized:
                    try:
                        connection_str = os.getenv("SERVICE_BUS")
                        queue_name = os.getenv("LOG_QUEUE_NAME", "logs")

                        if not connection_str or not queue_name:
                            print("Missing SERVICE_BUS or LOG_QUEUE_NAME environment variable.")
                            return

                        self._client = ServiceBusClient.from_connection_string(
                            conn_str=connection_str,
                            logging_enable=True
                        )
                        self._sender = self._client.get_queue_sender(queue_name=queue_name)
                        self._initialized = True
                        print("Service Bus client initialized")
                    except Exception as e:
                        print(f"Failed to initialize Service Bus client: {str(e)}")
                        self._client = None
                        self._sender = None
                        raise

    async def emit_async(self, record):
        try:
            await self._ensure_initialized()

            if not self._sender:
                print("Service Bus sender is not available")
                return

            async with self._connection_lock:
                log_entry = {
                    "timestamp": datetime.utcnow().isoformat(),
                    "level": record.levelname,
                    "message": record.getMessage(),
                    "module": record.module,
                    "function": record.funcName,
                    "line": record.lineno
                }

                message = ServiceBusMessage(
                    body=json.dumps(log_entry).encode('utf-8'),
                    content_type='application/json'
                )

                await self._sender.send_messages(message)
                print(f"Log message sent to Service Bus: {log_entry['message']}")
        except Exception as e:
            print(f"Error sending log to Service Bus: {str(e)}")
            self._initialized = False
            self._client = None
            self._sender = None

    async def close(self):
        try:
            if self._sender:
                await self._sender.close()
            if self._client:
                await self._client.close()
            if self._pending_tasks:
                await asyncio.gather(*self._pending_tasks, return_exceptions=True)
        except Exception as e:
            print(f"Error closing Service Bus client: {str(e)}")

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    service_bus_handler = ServiceBusLogHandler()
    service_bus_handler.setLevel(logging.INFO)
    logger.addHandler(service_bus_handler)

    return logger
