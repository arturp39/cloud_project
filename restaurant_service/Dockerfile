FROM python:3.11-slim

WORKDIR /app

ENV PYTHONPATH=/app

# Copy requirements first for caching
COPY restaurant_service/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy shared logging utility
COPY log_to_queue.py .

# Copy the restaurant service code
COPY restaurant_service/ .

# Start the service
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
