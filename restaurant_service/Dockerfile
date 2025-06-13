FROM python:3.11-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

COPY restaurant_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY log_to_queue.py .
COPY restaurant_service/ ./restaurant_service/

CMD ["sh", "-c", "uvicorn restaurant_service.main:app --host 0.0.0.0 --port ${PORT:-80}"]
