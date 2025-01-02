# Use slim Python image for smaller size
# Set working directory
# Install system dependencies
# Copy requirements first to leverage Docker cache
# Copy source code and templates
# Create data directory
# Set environment variables
# Run as non-root user for security
# Expose port
# Command to run the Flask app with gunicorn
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
COPY templates/ ./templates/
COPY static/ ./static/

RUN mkdir -p /data/analyzed

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app
ENV FLASK_APP=src/app.py
ENV FLASK_ENV=production
ENV PORT=5000

RUN useradd -m appuser && chown -R appuser:appuser /app /data
USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "src.app:app"]
