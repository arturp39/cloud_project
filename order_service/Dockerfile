FROM python:3.11-slim

WORKDIR /app
ENV PYTHONPATH=/app

COPY order_service/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY log_to_queue.py .

COPY order_service/ ./order_service/

CMD ["uvicorn", "order_service.main:app", "--host", "0.0.0.0", "--port", "8000"]