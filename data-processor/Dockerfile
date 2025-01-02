# Use slim Python image for smaller size
# Set working directory
# Install system dependencies
# Copy requirements first to leverage Docker cache
# Copy source code
# Create data directory
# Set environment variables
# Run as non-root user for security
# Command to run the processor
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

RUN mkdir -p /data/processed

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

RUN useradd -m appuser && chown -R appuser:appuser /app /data
USER appuser

CMD ["python", "src/processor.py"]
