FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Install dependencies
COPY delivery_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy files
COPY log_to_queue.py .
COPY delivery_service/ .

# Run the app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
